class DeployDocTest
  class Plan
    class AnnotationParser
      Annotation = Struct.new(:source_name, :line_span, :kind, :params, :content)

      def self.parse_file(file)
        AnnotationParser.new(File.read(file), file).parse!
      end

      def initialize(markdown, source_name="<unknown>")
        @source_name = source_name
        @markdown_lines = markdown.split("\n")
      end

      def parse!
        @annotations = []
        @parse_idx = 0

        while !eof_reached?
          parse_block || parse_inline || parse_single_line || parse_text
        end

        @annotations
      end

      private

      def parse_text
        inc_line # ignore text, line by line
      end

      BLOCK_START  = /^<!-- deploy-test-start (?<kind>[-\w]+)( )?(?<params>.*) -->/
      BLOCK_END    = /^<!-- deploy-test-end -->/

      INLINE_START = /^<!-- deploy-test-hidden (?<kind>[-\w]+)( )?(?<params>.*)/
      INLINE_END   = /^-->/

      SINGLE_LINE  = /^<!-- deploy-test (?<kind>[-\w]+)( )?(?<params>.*) -->/


      PARSE_METHOD_PREFIX = "parse_pragma_"

      def parse_block
        if (match = BLOCK_START.match(current_line)).nil?
          false
        else
          inc_line
          start_line = current_line_nr
          kind = match["kind"]
          params = match["params"].split(/\s+/)
          content = ""
          loop do
            if eof_reached?
              raise("Unexpected end of file; --> not closed? started on #{@source_name}:#{start_line}")
            elsif !(BLOCK_END.match(current_line).nil?)
              end_line = current_line_nr() -1
              @annotations << Annotation.new(@source_name, [start_line, end_line], kind, params, content)
              return true
            else
              content += current_line + "\n"
            end
            inc_line
          end
          true
        end
      end

      def parse_inline
        if (match = INLINE_START.match(current_line)).nil?
          false
        else
          inc_line
          start_line = current_line_nr
          kind = match["kind"]
          params = match["params"].split(/\s+/)
          content = ""
          loop do
            if eof_reached?
              raise("Unexpected end of file; --> not closed? started on #{@source_name}:#{start_line}")
            elsif !(INLINE_END.match(current_line).nil?)
              end_line = current_line_nr() -1
              @annotations << Annotation.new(@source_name, [start_line, end_line], kind, params, content)
              return true
            else
              content += current_line + "\n"
            end
            inc_line
          end
          true
        end
      end

      def parse_single_line
        if (match = SINGLE_LINE.match(current_line)).nil?
          false
        else
          kind = match["kind"]
          params = match["params"].split(/\s+/)
          @annotations << Annotation.new(@source_name, [current_line_nr, current_line_nr], kind, params, nil)
          inc_line
        end
      end

      ##### Helper functions ####

      def eof_reached?
        @parse_idx >= @markdown_lines.length
      end

      def current_line
        @markdown_lines[@parse_idx]
      end

      def current_line_nr
        @parse_idx + 1
      end

      def inc_line
        @parse_idx+=1
      end
    end
  end
end
