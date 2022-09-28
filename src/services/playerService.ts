import { PlayerRepository } from '../repositories/playerRepository';

export class PlayerService {
  private repository: PlayerRepository;
  constructor(repository: PlayerRepository = new PlayerRepository()) {
    this.repository = repository;
  }

  public async getAll() {
    const result = await this.repository.getAll();
    const players: any[] = [];
    result.forEach((player: { toJson: () => any }) => {
      players.push(player.toJson());
    });
    return players;
  }
}
