require 'telemetry/number_helper'

module Telemetry
  module IFQL
    class Parser
      include Telemetry::NumberHelper
      attr_reader :query, :database, :params

      def initialize(query, db: 'telegraf', **params)
        @original_query = query
        @query = query.downcase
        if @query.include? 'ms'
          @query.scan(/(\d+)ms/).flatten.each do |ms_time|
            @query.sub! "#{ms_time}ms", (ms_time.to_f.round(-4) / 1000).to_s
          end
        end

        @database = db
        @params = params
        @time_filter = nil
        @limit_processed = false
      end

      def query_type(query: @query)
        @query_type ||= if query.include? ';'
                          :multi_data
                        elsif query.include?('show measurements')
                          :measurement
                        elsif query.include? 'show databases'
                          :database
                        elsif query.include? 'show retention policies'
                          :rp
                        elsif query.include? 'show field keys'
                          :field_key
                        elsif query.include? 'show tag keys'
                          :tag_key
                        elsif query.include? 'show tag values'
                          :tag_value
                        elsif query.include? 'show series'
                          :series
                        else
                          :data
                        end
      end

      def measurement(query = @query)
        @measurement ||= if query.include?('from')
                           query.split('from').last.split.first.split('.').last.tr('"', '')
                         elsif query.include?('with measurement')
                           query.split('with measurement').last.split('/')[1]
                         end
      end

      def limit?
        return !limit.nil? if @limit_processed

        !limit.nil?
      end

      def limit(query = @query)
        return @limit if @limit_processed && @limit.is_a?(Integer)
        return nil unless query.include? 'limit'

        limit = query.split('limit').last.split.first
        return nil unless integer?(limit)

        @limit_processed = true
        @limit = limit.to_i
      end

      def time_filter?
        !@time_filter.nil? if @time_filter_processed

        conditions.each do |cond|
          if cond.include?('time')
            @time_filter = cond
            break
          end
        end

        @time_filter_processed = true

        !@time_filter.nil?
      end

      def conditions(query = @query)
        return @conditions unless @conditions.nil?
        return @conditions = [] unless query.include?('where')

        @conditions = query.split('where').last
        @conditions = @conditions.split('group').first if @conditions.include?('group')
        @conditions = @conditions.split('fill').first if @conditions.include?('fill')
        @conditions = @conditions.split('and').collect { |e| e.strip.tr('\\', '') }
        @conditions.collect do |cond|
          cond.chop! if cond[-1, 1] == ')' && cond[-2, 1] != '('
          cond[0] = '' if cond[0] == '('
        end

        @conditions
      rescue StandardError
        []
      end

      def group_by(query = @query)
        @group_by ||= query.split('group by')[1].split('fill').first.tr('\\', '').split(',').collect(&:strip)
      rescue StandardError
        []
      end

      def group_by_time
        @group_by_time unless @group_by_time
        @group_by_time = nil
        group_by.each do |group|
          next unless group.include?('time')

          @group_by_time = group.split('(')[1].split(')').first.split(',').first
          temp_time = @group_by_time.include?('h') ? @group_by_time.split('h').first.to_i * 60 * 60 : 0

          if @group_by_time.include?('h') && @group_by_time.include?('m')
            temp_time += @group_by_time.split('h').last.split('m').first.to_i * 60
          elsif @group_by_time.include? 'm'
            temp_time += @group_by_time.split('m').first.to_i * 60
          end

          if @group_by_time.include?('s') && @group_by_time.include?('m')
            temp_time += @group_by_time.split('s').first.to_i
          elsif @group_by_time.include?('s')
            temp_time += @group_by_time.split('m').last.split('s').first.to_i
          end

          @group_by_time = temp_time
          break
        end
        @group_by_time
      end

      def group_by_time?
        @group_by_time unless @group_by_time.nil?
        group_by.each do |group|
          if group.include?('time')
            @group_by_time = true
            break
          end
        end

        @group_by_time = false if @group_by_time.nil?
        @group_by_time
      end
    end
  end
end
