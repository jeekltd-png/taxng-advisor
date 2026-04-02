module.exports = {
  testEnvironment: 'node',
  collectCoverage: true,
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/index.js',
    '!src/public/**'
  ],
  coveragePathIgnorePatterns: [
    '/node_modules/',
    '/__tests__/'
  ],
  // Coverage thresholds - adjust as test coverage improves
  // Current: 48% statements, 52% lines, 53% functions, 22% branches
  coverageThreshold: {
    global: {
      branches: 15,
      functions: 45,
      lines: 45,
      statements: 45
    }
  },
  testMatch: [
    '**/__tests__/**/*.test.js'
  ],
  verbose: true,
  forceExit: true,
  clearMocks: true,
  resetMocks: true,
  restoreMocks: true
};

