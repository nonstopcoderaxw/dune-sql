import { parse } from "csv-parse/sync";
import { stringify } from "csv-stringify/sync";
import { jsonrepair } from "jsonrepair";

const number_cols = [
  "block_number",
  "block_number",
  "value",
  "gas_limit",
  "gas_price",
  "gas_used",
  "max_fee_per_gas",
  "max_priority_fee_per_gas",
  "priority_fee_per_gas",
  "nonce",
  "index",
];

export const fix_rows = (csv_string) => {
  csv_string = csv_string.replaceAll("<nil>", "");

  const records = parse(csv_string, {
    columns: true,
    skip_empty_lines: true,
  });

  const fixed_records = records.map((cols) => {
    number_cols.forEach((item) => {
      if (cols[item]) {
        cols[item] = cols[item] !== "" ? Number(cols[item]) : "";
      }
    });

    if (cols["trace_address"]) {
      cols["trace_address"] = cols["trace_address"]
        .replace("[", "{")
        .replace("]", "}")
        .replaceAll(" ", ",");
    }

    if (cols["abi"]) {
      cols["abi"] = jsonrepair(cols["abi"]);
    }

    return cols;
  });

  return stringify(fixed_records, {
    header: true,
  });
};
