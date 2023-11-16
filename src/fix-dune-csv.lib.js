import { parse } from "csv-parse/sync";
import { stringify } from "csv-stringify/sync";
import { jsonrepair } from "jsonrepair";

export const fix_rows = (csv_string) => {
  const records = parse(csv_string, {
    columns: true,
    skip_empty_lines: true,
  });

  const fixed_records = records.map((cols) => {
    if (cols["block_number"]) {
      cols["block_number"] = Number(cols["block_number"]);
    }

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
