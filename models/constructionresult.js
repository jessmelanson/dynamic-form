import { Schema, model } from 'mongoose';

const constructionResultSchema = new Schema({
  uuid: {
    type: String,
    required: true
  },
  extendedConstructionNumbers: {
    type: String,
    required: true
  },
  lookUpConstructionNumber: {
    type: String,
    required: true
  },
  notes: {
    type: String,
    required: false
  }
});

const ConstructionResult = model('ConstructionResult', constructionResultSchema);

export default ConstructionResult;