/* 
 * File:   main.cpp
 * Author: mathi
 *
 * Created on 18 September, 2020, 6:21 PM
 */

#include <Wt/WApplication.h>
#include <Wt/WBreak.h>
#include <Wt/WContainerWidget.h>
#include <Wt/WLineEdit.h>
#include <Wt/WPushButton.h>
#include <Wt/WText.h>
#include <Wt/WHBoxLayout.h>
#include <Wt/WVBoxLayout.h>
#include <Wt/WText.h>
#include <Wt/WTextArea.h>
#include <Wt/WSignal.h>
#include "WCodeMirrorTextArea.h"
#include <Wt/WJavaScript.h>

#include <iostream>
#include <string> 
#include <vector> 
#include <cstring>
#include <mutex>



extern "C" void _cb_beautify(char* src, char* dest, int srclength);
/*
 * A CBeauty application class 
 */
class CBeautyApp : public Wt::WApplication
{
public:
  CBeautyApp(const Wt::WEnvironment& env);

private:
  //Wt::WTextArea *sourcetextarea_;
  Wt::WCodeMirrorTextArea * cmta_;
  void beautify();
  std::mutex asmFuncMutex_;
};

/*
 * The env argument contains information about the new session, and
 * the initial request. It must be passed to the WApplication
 * constructor so it is typically also an argument for your custom
 * application constructor.
*/
CBeautyApp::CBeautyApp(const Wt::WEnvironment& env)
  : WApplication(env)
{
  setTitle("C/C++ Source Code Beautifier");                            // application title
  
  WApplication * app = WApplication:: instance();
//  counter = 1;
    
  app->useStyleSheet(app->resolveRelativeUrl("codemirror-5.22.0/lib/codemirror.css"));
  app->useStyleSheet("https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/css/materialize.min.css");
  app->useStyleSheet("https://fonts.googleapis.com/icon?family=Material+Icons");
  app->require(app->resolveRelativeUrl("codemirror-5.22.0/lib/codemirror.js"));

  app->require(app->resolveRelativeUrl("codemirror-5.22.0/mode/clike/clike.js"));
  app->require(app->resolveRelativeUrl("codemirror-5.22.0/addon/selection/active-line.js"));
  //app->useStyleSheet(app->resolveRelativeUrl("codemirror-5.22.0/addon/hint/show-hint.css"));

  //app->require(app->resolveRelativeUrl("codemirror-5.22.0/addon/hint/show-hint.js"));
  //app->require(app->resolveRelativeUrl("codemirror-5.22.0/addon/hint/sql-hint.js"));
  //app->useStyleSheet(app->resolveRelativeUrl("codemirror-5.22.0/doc/docs.css"));
  //app->useStyleSheet("CSSexample.css");

  require("https://code.jquery.com/jquery-3.5.1.min.js");
  require("https://cdnjs.cloudflare.com/ajax/libs/materialize/1.0.0/js/materialize.min.js");
		
  
  Wt::WApplication::instance()->styleSheet().addRule(Wt::cpp14::make_unique<Wt::WCssTextRule>(".breakpoints", "width: .8em;"));
  Wt::WApplication::instance()->styleSheet().addRule(Wt::cpp14::make_unique<Wt::WCssTextRule>(".breakpointline", "background : #FF6666;"));
  Wt::WApplication::instance()->styleSheet().addRule(Wt::cpp14::make_unique<Wt::WCssTextRule>(".executionline", "background : yellow;"));
  Wt::WApplication::instance()->styleSheet().addRule(Wt::cpp14::make_unique<Wt::WCssTextRule>(".CodeMirror", "border: 1px solid #cccccc;"));
          
  root()->addWidget(Wt::cpp14::make_unique<Wt::WBreak>()); 
  Wt::WText *cbeautytext = root()->addWidget(Wt::cpp14::make_unique<Wt::WText>("<span style='font-family:Agency FB; font-size: 16pt; font-weight:bold'>CBeauty - C/C++ Code Beautifier</span>"));
        
  auto gamecontainer = root()->addWidget(Wt::cpp14::make_unique<Wt::WContainerWidget>());
  //root()->setContentAlignment(Wt::AlignmentFlag::Center);
  auto mainvbox = gamecontainer->setLayout(Wt::cpp14::make_unique<Wt::WVBoxLayout>());
  //gamecontainer->setContentAlignment(Wt::AlignmentFlag::Center);
  auto hbox = Wt::cpp14::make_unique < Wt::WHBoxLayout>();
  hbox->addWidget(Wt::cpp14::make_unique<Wt::WText>(" "));
  hbox->addWidget(Wt::cpp14::make_unique<Wt::WText>(" "));
  
  auto btfybutton = hbox->addWidget(Wt::cpp14::make_unique<Wt::WAnchor>("", "Beautify!"));
  hbox->addWidget(Wt::cpp14::make_unique<Wt::WText>(" "));
  hbox->addWidget(Wt::cpp14::make_unique<Wt::WText>(" "));
  
  mainvbox->addLayout(std::move(hbox));
  //auto undoIcon_ = undoButton->addWidget(Wt::cpp14::make_unique<Wt::WAnchor>("", "undo"));
  //undoIcon_->setHtmlTagName("i");
  //undoIcon_->setStyleClass("material-icons left");
  btfybutton->setStyleClass("waves-effect teal waves-light btn-large z-depth-2");

  //auto btfybutton = mainvbox->addWidget(Wt::cpp14::make_unique<Wt::WPushButton>("Beautify!!"));
  btfybutton->setWidth(200);
  
  mainvbox->addWidget(Wt::cpp14::make_unique<Wt::WBreak>()); 
  
  cmta_ = mainvbox->addWidget(Wt::cpp14::make_unique<Wt::WCodeMirrorTextArea>());
  cmta_->setText("Paste your ugly C/C++ code here and Click 'Beautify!'");
  btfybutton->clicked().connect(this, &CBeautyApp::beautify);

  
}

void CBeautyApp::beautify()
{
    std::lock_guard<std::mutex> lk(asmFuncMutex_);
            
    std::string srctext  = cmta_->getText();
    //char srcwritable[500],dest[500];
    
    char *srcwritable,*dest;
    unsigned int noOfBytes = (srctext.length() * 2 * sizeof (char)) + 10;  //2N + 10
    srcwritable = (char*) malloc (noOfBytes);
    strcpy(srcwritable,srctext.c_str());
    
    dest = (char*) malloc(noOfBytes);
    memset(dest, 0, noOfBytes);
    
    _cb_beautify(srcwritable, dest, srctext.length());
    
    cmta_->setText(dest);
    //printf ("dest len : %d", strlen(dest));
    free (srcwritable);
    free (dest);
    
}

int main(int argc, char **argv)
{
  /*
   * Your main method may set up some shared resources, but should then
   * start the server application (FastCGI or httpd) that starts listening
   * for requests, and handles all of the application life cycles.
   *
   * The last argument to WRun specifies the function that will instantiate
   * new application objects. That function is executed when a new user surfs
   * to the Wt application, and after the library has negotiated browser
   * support. The function should return a newly instantiated application
   * object.
   */
  return Wt::WRun(argc, argv, [](const Wt::WEnvironment &env) {
    /*
     * You could read information from the environment to decide whether
     * the user has permission to start a new application
     */
    return Wt::cpp14::make_unique<CBeautyApp>(env);
  });
}

