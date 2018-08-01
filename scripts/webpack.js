module.exports = function () {
  return {
    // This will run the `webpack` command on each build.
    //
    // The following environment variables will be set when running the command:
    // WORKING_DIRECTORY: root location of the project
    // BUILD_DESTINATION_DIRECTORY: expected destination of built assets (important for `truffle serve`)
    // BUILD_CONTRACTS_DIRECTORY: root location of your build contract files (.sol.js)
    //
    build: 'webpack',
  };
};
