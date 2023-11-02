import fs from "fs";
import { fix_block_number } from "./fix-dune-csv.lib.js";

const CSV_FILE_NAME = "results_3026250.csv";
const csv_string = fs.readFileSync("results_3026250.csv").toString();

fix_block_number(csv_string);