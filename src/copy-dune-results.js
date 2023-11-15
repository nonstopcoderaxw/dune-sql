import fs from "fs";
import { fix_block_number } from "./fix-dune-csv.lib.js";
import dotenv from 'dotenv';
dotenv.config();

const dest = process.argv[2]; // the first arg
const CSV_FILE_NAME = process.env.QUERY_RESULT_FILE;
let csv_string = fs.readFileSync(CSV_FILE_NAME).toString();
if (!dest) {
    console.error("Error: Dest Path Not Given!"); 
    process.exit();
}

fs.writeFile(dest, csv_string, (err) => {
  if (err) {
    console.error(`Error writing the CSV file: ${dest}`, err);
  } else {
    console.log(`CSV file has been saved as ${dest}`);
  }
});
