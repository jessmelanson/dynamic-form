import mongoose from 'mongoose';
import Question from '../models/question.js';
import ConstructionResult from '../models/constructionresult.js';
import { MongoMemoryServer } from 'mongodb-memory-server';

let uri = '';

const startDatabase = async () => {
  const mongod = await MongoMemoryServer.create();
  uri = mongod.getUri();
  await mongoose.connect(uri);
};

const getMongoUri = () => uri;

const createQuestion = async (
  uuid,
  prompt,
  answers,
  nextItemUuids,
  nextItemTypes
) => {
  try {
    const newQuestion = new Question({
      uuid,
      prompt,
      answers,
      nextItemUuids,
      nextItemTypes
    });

    return await newQuestion.save();
  } catch (err) {
    throw err;
  }
};

const getQuestion = async (uuid) => {
  try {
    return await Question.findOne({ uuid });
  } catch (err) {
    throw err;
  }
};

const createConstructionResult = async (
  uuid,
  extendedConstructionNumbers,
  lookUpConstructionNumber,
  notes
) => {
  try {
    const newConstructionResult = new ConstructionResult({
      uuid: uuid,
      extendedConstructionNumbers,
      lookUpConstructionNumber,
      notes
    });

    return await newConstructionResult.save();
  } catch (err) {
    throw err;
  }
};

const getConstructionResult = async (uuid) => {
  try {
    return await ConstructionResult.findOne({ uuid });
  } catch (err) {
    throw err;
  }
};

const DatabaseManager = {
  startDatabase,
  getMongoUri,
  createQuestion,
  getQuestion,
  createConstructionResult,
  getConstructionResult
};

export default DatabaseManager;