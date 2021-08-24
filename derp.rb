# code = 'ou:hello:va:x:10'

# raised when no label with a name is found
class NoLabelFoundException < StandardError
    def initialize msg
        super msg
    end
end

class ReadTheDocsException < StandardError
    def initialize msg='invalid command passed'
        super msg
    end
end

class NoVariableFoundException < StandardError
    def initialize msg
        super msg
    end
end

class Derp
    def initialize code
        if code.class != String
            raise 'Code needs to be a string!'
        end

        @code = code.split ':'
        @loc = 0
        @labels = {
            "END" => @code.length
        }
        @variables = Hash.new
        @defined_commands = {
            "va" => method(:variable),
            "ou" => method(:output),
            "un" => method(:unset),
            "ip" => method(:input),
            "in" => method(:input_with_prompt),
            "go" => method(:goto_label),
            "co" => method(:concat),
            "ad" => method(:add),
            "su" => method(:subtract),
            "mu" => method(:multiply),
            "di" => method(:divide),
            "eq" => method(:equals),
            "gt" => method(:greater_than),
            "lt" => method(:less_than)
        }
    end

    def scan_labels
        pointer = 0

        while pointer < @code.length
            if @code[pointer] != 'la'
                pointer += 1
                next
            end

            label_name = @code[pointer + 1]
            @labels[label_name] = pointer
            pointer += 1
        end
    end

    def math math_lambda
        key = @code[@loc + 1]
        var1 = @code[@loc + 2]
        var2 = @code[@loc + 3]

        value = math_lambda.call var1.to_f, var2.to_f

        @variables[key] = value

        @loc += 4
    end
    
    def add
        math -> (x, y) { x + y }
    end

    def subtract
        math -> (x, y) { x - y }
    end

    def multiply
        math -> (x, y) { x * y }
    end

    def divide
        math -> (x, y) { x / y }
    end

    def comparison_goto comparison_lambda
        var1 = @code[@loc + 1]
        var2 = @code[@loc + 2]

        if @variables.key? var1
            value1 = @variables[var1]
        else
            value1 = var1
        end

        if @variables.key? var2
            value2 = @variables[var2]
        else
            value2 = var2
        end

        if comparison_lambda.call value1, value2
            jump_to @code[@loc + 3]
        else
            jump_to @code[@loc + 4]
        end
    end

    def equals
        comparison_goto -> (x, y) { x == y }
    end

    def greater_than
        comparison_goto -> (x, y) { x > y }
    end

    def less_than
        comparison_goto -> (x, y) { x < y }
    end

    def goto_label
        label = @code[@loc + 1]
        jump_to label
    end

    def jump_to label
        if !@labels.key? label
            raise NoLabelFoundException.new "label: '#{label}' was not found"
        end

        @loc = @labels[label]
    end

    def variable
        key = @code[@loc + 1]
        value = @code[@loc + 2]
        @variables[key] = value

        @loc += 3
    end

    def unset
        key = @code[@loc + 1]

        @variables.delete(key) { |x| raise NoVariableFoundException.new "#{x} not found" }

        @loc += 2
    end

    def output
        key = @code[@loc + 1]

        if @variables.key? key
            puts @variables[key]
        else
            puts key
        end

        @loc += 2
    end

    def input
        key = @code[@loc + 1]
        @variables[key] = gets.chomp

        @loc += 2
    end

    def input_with_prompt
        prompt = @code[@loc + 1]
        key = @code[@loc + 2]
        print "#{prompt}: "
        @variables[key] = gets.chomp

        @loc += 2
    end

    def concat
        key = @code[@loc + 1]
        value1, value2 = @code[@loc + 2], @code[@loc + 3]

        if @variables.key? value1 
            value1 = @variables[value1]
        end

        if @variables.key? value2 
            value2 = @variables[value2]
        end

        @variables[key] = value1 + value2

        @loc += 4
    end

    def run
        scan_labels
        while @loc < @code.length
            step
        end
    end

    def step
        current_statement = @code[@loc]
        
        unless @defined_commands.key? current_statement
            @loc += 1
            return
        end

        @defined_commands[current_statement].call
    end
end

derp = Derp.new "ou:hello world:"
derp.run