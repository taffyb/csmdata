import { Injectable } from '@angular/core';
import { BasicAuth } from 'src/types/BasicAuth';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private auth!:BasicAuth;

  constructor() { }

  public setAuth(user:string,pwd:string){
    this.auth= {user:user,pwd:pwd};
  }
  public getAuth():BasicAuth{
    return this.auth;
  }
}
