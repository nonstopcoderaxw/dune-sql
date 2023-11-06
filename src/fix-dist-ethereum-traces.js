import fs from "fs";
import { fix_block_number } from "./fix-dune-csv.lib.js";
import dotenv from 'dotenv';
dotenv.config();

const CSV_FILE_NAME = process.env.QUERY_RESULT_FILE;
let csv_string = fs.readFileSync(CSV_FILE_NAME).toString();

// fix block number
csv_string = fix_block_number(csv_string);

fs.writeFile(CSV_FILE_NAME, csv_string, (err) => {
  if (err) {
    console.error(`Error writing the CSV file: ${CSV_FILE_NAME}`, err);
  } else {
    console.log(`CSV file has been saved as ${CSV_FILE_NAME}`);
  }
});
