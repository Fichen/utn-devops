import { Player } from '../domain/player';
import { sqlClient } from './dbClient';

export class PlayerRepository {
  public async getAll(): Promise<Player[]> {
    let players: Player[] = [];
    const a = await sqlClient
      .query('SELECT * FROM `players`')
      .then((results) => {
        Object.entries(results[0]).forEach((item) => {
          const [_, value] = item;
          players.push(new Player(value));
        });

        return players;
      })
      .catch((error) => {
        console.log('Error', error.message);
      });
    return players;
  }
}
