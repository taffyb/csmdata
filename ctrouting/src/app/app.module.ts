import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppComponent } from './app.component';
import { RouteComponent } from './route/route.component';
import { NodeComponent } from './node/node.component';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { PathSegmentComponent } from './path-segment/path-segment.component';
import { RelationshipComponent } from './relationship/relationship.component';
import { TooltipModule } from './tooltip/tooltip.module';

@NgModule({
  declarations: [
    AppComponent,
    RouteComponent,
    NodeComponent,
    PathSegmentComponent,
    RelationshipComponent
    // ,
    // TooltipComponent
  ],
  imports: [
    BrowserModule,
    FormsModule,
    HttpClientModule,
    TooltipModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
