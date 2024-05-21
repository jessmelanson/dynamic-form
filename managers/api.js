import express from 'express';
const { Express, Request, Response, Application } = express;
import dotenv from 'dotenv';
import DatabaseManager from './database.js';
import CSVParser from './parser.js';

const startAPI = async () => {
  dotenv.config();

  const app = express();
  const port = process.env.PORT || 8000;

  app.get('/question/ceiling-type', async (req, res) => {
    try {
      console.log('Request to /question/ceiling-type');
      const uuid = CSVParser.getFirstQuestionUuid();
      const question = await DatabaseManager.getQuestion(uuid);
      const response = {
        uuid: question.uuid,
        prompt: question.prompt,
        answers: question.answers,
        nextItemUuids: question.nextItemUuids,
        nextItemTypes: question.nextItemTypes
      };
      console.log(`Response sent: ${JSON.stringify(response)}`);
      res.send(response);
    } catch(err) {
      console.log(err);
      res.status(500).send(err);
    }
  });

  app.get('/question/:questionUuid', async (req, res) => {
    try {
      const questionUuid = req.params.questionUuid;
      console.log(`Request to /question/${questionUuid}`);
      const question = await DatabaseManager.getQuestion(questionUuid);
      let response = {
        uuid: question?.uuid,
        prompt: question?.prompt,
        answers: question?.answers,
        nextItemUuids: question?.nextItemUuids,
        nextItemTypes: question?.nextItemTypes
      };
      console.log(`Response sent: ${JSON.stringify(response)}`);
      res.send(response);
    } catch(err) {
      console.log(err);
      res.status(500).send(err);
    }
  });

  app.get('/result/:uuid', async (req, res) => {
    try {
      const resultUuid = req.params.uuid;
      console.log(`Request to /response/${resultUuid}`);
      const result = await DatabaseManager.getConstructionResult(resultUuid);
      let response = {
        uuid: result.uuid,
        extendedConstructionNumbers: result.extendedConstructionNumbers,
        lookUpConstructionNumber: result.lookUpConstructionNumber,
        notes: result.notes
      };
      console.log(`Response sent: ${JSON.stringify(response)}`);
      res.send(response);
    } catch(err) {
      console.log(err);
      res.status(500).send(err);
    }
  });

  app.listen(port, () => {
    console.log(`API started at http://localhost:${port}`);
  });
};

const APIManager = { startAPI };

export default APIManager;