import { Schema, model } from 'mongoose';

const questionSchema = new Schema({
  uuid: {
    type: String,
    required: true
  },
  prompt: {
    type: String,
    required: true
  },
  answers: {
    type: [String],
    required: true
  },
  nextItemUuids: {
    type: [String],
    required: true
  },
  nextItemTypes: {
    type: [String],
    required: true
  }
});

const Question = model('Question', questionSchema)

export default Question;