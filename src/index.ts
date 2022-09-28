import express from 'express';
import { PlayerService } from './services/playerService';

const app = express();
const PORT = 3000;

app.get('/players', async (_, res) => {
  try {
    const service = new PlayerService();
    res.json(await service.getAll());
  } catch (error) {
    res.json(error);
  }
});

app.listen(PORT, () => {
  console.log(`Express server is listening at port ${PORT}`);
});
