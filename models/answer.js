import { Schema, model } from 'mongoose';

const answerSchema = new Schema({
  uuid: {
    type: String,
    required: true
  },
  text: {
    type: String,
    required: true
  },
  questionUuid: {
    type: String,
    required: true
  },
  nextQuestionUuid: {
    type: String,
    required: true
  }
});

const Answer = model('Answer', answerSchema)

export default Answer;