module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
  },
  extends: ["eslint:recommended", "google"],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": "off",
    "indent": "off",
    "max-len": "off",
    "require-jsdoc": "off",
    "object-curly-spacing": "off",
    "comma-dangle": "off",
    "quote-props": "off",
    "eol-last": "off",
    "operator-linebreak": "off",
    "arrow-parens": "off",
    "new-cap": "off",
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};