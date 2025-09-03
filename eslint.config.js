const js = require('@eslint/js');

module.exports = [
  js.configs.recommended,
  {
    rules: {
      'curly': ['error', 'multi-line'],
      'eqeqeq': ['error', 'smart'],
      'indent': ['error', 2],
      'no-console': 'warn',
      'no-var': 'error',
      'prefer-const': 'error',
      'quotes': ['error', 'single'],
      'semi': ['error', 'always'],
      'strict': ['error', 'global']
    }
  },
  {
    files: ['eslint.config.js'],
    languageOptions: {
      sourceType: 'commonjs'
    },
    rules: {
      'strict': 'off'
    }
  },
  {
    files: ['public/**/*.js'],
    languageOptions: {
      sourceType: 'script',
      globals: {
        document: 'readonly',
        window: 'readonly'
      }
    }
  }
];