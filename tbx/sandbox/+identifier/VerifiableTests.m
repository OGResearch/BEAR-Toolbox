%
% VerifiableTests  Container for verifiable test functions
%

classdef VerifiableTests

    properties
        TestFunctions (1, :) cell
    end

    methods
        function this = VerifiableTests(testStrings)
            arguments
                testStrings (1, :) string
            end
            this.TestFunctions = cell(size(testStrings));
            for i = 1 : numel(testStrings)
                this.TestFunctions{i} = this.testFuncFromTestString(testStrings(i));
            end
        end%

        function status = evaluateAll(this, verifiableProperties)
            arguments
                this
                verifiableProperties (1, 1) identifier.VerifiableProperties
            end
            % status = repmat(false, size(this.TestFunctions));
            status = cell(size(this.TestFunctions));
            for i = 1 : numel(this.TestFunctions)
                status{i} = this.TestFunctions{i}(verifiableProperties);
            end
        end%

        function status = evaluateShortCircuit(this, verifiableProperties)
            arguments
                this
                verifiableProperties (1, 1) identifier.VerifiableProperties
            end
            for i = 1 : numel(this.TestFunctions)
                status = this.TestFunctions{i}(verifiableProperties);
                if ~status
                    break
                end
            end
        end%
    end

    methods
        function testFunc = testFuncFromTestString(this, testString)
            % Replace $SHKRESP with x.extractSHKRESP, etc.
            funcString = regexprep(testString, "\$(\w+)", "x.extract$1");
            testFunc = str2func("@(x)" + funcString);
        end%
    end

end

