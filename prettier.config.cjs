/** @type {import("prettier").Config} */
const config = {
  trailingComma: "es5",
  semi: true,
  singleQuote: false,
  plugins: ["prettier-plugin-sh"],
};

module.exports = config;
