var testsContext = require.context(".", true, /-test\.(jsx|js)$/);
testsContext.keys().forEach(testsContext);
