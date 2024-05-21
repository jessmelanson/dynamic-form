import CSVParser from './managers/parser.js';
import mongoose from 'mongoose';
import Question from './models/question.js';
import ConstructionResult from './models/constructionresult.js';
import DatabaseManager from './managers/database.js';
import APIManager from './managers/api.js';

DatabaseManager.startDatabase()
  .then(() => console.log(`Database started at ${DatabaseManager.getMongoUri()}`))
  .then(() => CSVParser.processFile())
  .then(() => Promise.all([Question.find(), ConstructionResult.find()]))
  .then(([questions, results]) => {
    console.log(`Wrote ${questions.length} questions and ${results.length} results to database`);
  }).then(() => APIManager.startAPI());