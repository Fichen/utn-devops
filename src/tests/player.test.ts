import { Player } from '../domain/player';

describe('Players', () => {
  test('should display a birthday date with format dd/mm/yyyy when a timestamp is given', () => {
    const input = {
      id: 1,
      firstName: 'Lionel',
      lastName: 'Messi',
      birthday: 551502000000,
    };
    const expectedDate = '24/06/1987';

    const messiJson = new Player(input).toJson();

    expect(messiJson.birthday).toEqual(expectedDate);
  });
});
