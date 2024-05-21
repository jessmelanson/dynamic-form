import fs from 'node:fs';
import os from 'node:os';
import { parse } from 'csv-parse';
import path from 'path';
import { fileURLToPath } from 'url';
import DatabaseManager from './database.js';
import ConstructionResult from '../models/constructionresult.js';
import { v4 as uuidv4 } from 'uuid';

let firstQuestionUuid = '';

const getFirstQuestionUuid = () => firstQuestionUuid;

const processFile = async () => {
  const records = [];
  const __filename = fileURLToPath(import.meta.url);
  const __dirname = path.dirname(__filename);
  const parser = fs
    .createReadStream(path.join(__dirname, '../data/ceiling-construction.csv'))
    .pipe(parse({ columns: true }));
  for await (const record of parser) {
    records.push(record);
  }
  await transform(records);
  return records;
};

const transform = async (parsedArray) => {
  if (parsedArray.length === 0) { return; }

  // Get question prompts
  const keys = Object.keys(parsedArray[0]);
  const extendedConstructionNumbers = 'Extended Construction Numbers';
  const extendedConstructionNumbersIndex = keys.indexOf(extendedConstructionNumbers);
  const questionPrompts = keys.slice(0, extendedConstructionNumbersIndex).map(question => [question, uuidv4()]);
  firstQuestionUuid = questionPrompts[0][1];

  // Initial question data structure to use
  let questions = questionPrompts.reduce((acc, prompt, idx, arr) => {
    acc[prompt[0]] = {
      uuid: prompt[1],
      answers: [],
      nextItemUuids: [],
      nextItemTypes: []
    };
    return acc;
  }, {});

  // results metadata
  let results = {};

  // Add data to each question/result object
  parsedArray.slice(1).forEach((obj, idx, arr) => {
    const resultUuid = uuidv4();
    results[obj[extendedConstructionNumbers]] = {
      uuid: resultUuid,
      lookUpConstructionNumber: obj['Look-Up Construction Number'],
      notes: obj['Notes']
    };

    Object.entries(obj).slice(0, extendedConstructionNumbersIndex).forEach(([key, value], idx, arr) => {
      // add data to questions object
      if (!questions[key].answers.includes(value) && value !== '') {
        questions[key].answers.push(value);

        // add uuid of next question if there is a next question
        const nextNonEmptyValueIndex = arr.slice(idx + 1).findIndex(([key, value]) => value !== '');
        if (nextNonEmptyValueIndex > -1) {
          questions[key].nextItemUuids.push(questionPrompts[nextNonEmptyValueIndex + idx + 1][1]);
          questions[key].nextItemTypes.push("question");
        // add uuid of result if there is no next question
        } else {
          questions[key].nextItemUuids.push(resultUuid);
          questions[key].nextItemTypes.push("result");
        }
      }
    });
  });

  // Write questions to database
  await Promise.all(Object.entries(questions).map(([key, value]) => {
    DatabaseManager.createQuestion(value.uuid, key, value.answers, value.nextItemUuids, value.nextItemTypes);
  }));

  // Write results to database
  await Promise.all(Object.entries(results).map(([key, value]) => {
    DatabaseManager.createConstructionResult(
      value.uuid,
      key,
      value.lookUpConstructionNumber,
      value.notes
    );
  }));
};

const CSVParser = { getFirstQuestionUuid, processFile };

export default CSVParser;
