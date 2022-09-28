export class Player {
  private id: number;
  private firstName: string;
  private lastName: string;
  private birthday: number;

  constructor({
    id,
    firstName,
    lastName,
    birthday,
  }: {
    id: number;
    firstName: string;
    lastName: string;
    birthday: number;
  }) {
    this.id = id;
    this.firstName = firstName;
    this.lastName = lastName;
    this.birthday = birthday;
  }

  public toJson(): {
    id: number;
    firstName: string;
    lastName: string;
    birthday: string;
  } {
    return {
      id: this.id,
      firstName: this.firstName,
      lastName: this.lastName,
      birthday: new Date(this.birthday).toLocaleDateString('es-ES', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
      }),
    };
  }
}
