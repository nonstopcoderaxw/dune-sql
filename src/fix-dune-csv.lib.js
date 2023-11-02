import { parse } from "csv-parse/sync";
import fs from "fs";

export const fix_block_number = (csv_string) => {
  const records = parse(csv_string, {
    columns: true,
    skip_empty_lines: true,
  });

  const column_two = records.map((rec) => rec["block_number"]);
  console.log("column_two", column_two);
  // TBC fix the block number and then return csv_string
};
