%
% VerifiableTests  Container for verifiable test functions
%

classdef VerifiableTests

    properties
        TestStrings (1, :) string
        TestFunctions (1, :) cell
        TestFunctionShortCircuit
    end

    methods
        function this = VerifiableTests(testStrings)
            arguments
                testStrings (1, :) string
            end
            this.TestStrings = testStrings;
            this.TestFunctions = cell(size(testStrings));
            for i = 1 : numel(testStrings)
                this.TestFunctions{i} = this.testFuncFromTestString(testStrings(i));
            end
            this.TestFunctionShortCircuit = this.testFuncFromTestString( ...
                join("(" + testStrings + ")", " && ") ...
            );
        end%

        function status = evaluateAll(this, verifiableProperties)
            arguments
                this
                verifiableProperties (1, 1) identifier.VerifiableProperties
            end
            numTestFunctions = numel(this.TestFunctions);
            status = false(numTestFunctions, 1);
            for i = 1 : numel(this.TestFunctions)
                status(i) = this.TestFunctions{i}(verifiableProperties);
            end
        end%

        function status = evaluateShortCircuit(this, verifiableProperties)
            arguments
                this
                verifiableProperties (1, 1) identifier.VerifiableProperties
            end
            status = false(1, 1);
            status(1) = this.TestFunctionShortCircuit(verifiableProperties);
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

