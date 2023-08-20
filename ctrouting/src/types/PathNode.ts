export class PathNode{
  public name!:string;
  public id!:string;
  public type!:string;
  constructor(id:string, name:string, type:string){
    this.name=name;
    this.id=id;
    this.type=type;
  }
}
