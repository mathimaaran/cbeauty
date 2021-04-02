/* 
 * File:   WCodeMirrorTextArea.h
 * Author: mathi
 *
 * Created on 24 April, 2016, 10:17 PM
 */

#ifndef WT_WCodeMirrorTextArea
#define WT_WCodeMirrorTextArea

#include <Wt/WApplication.h>
#include <Wt/WTextArea.h>
#include <Wt/WContainerWidget.h>
#include <string>
#include <sstream>
#include <mutex>
#include <condition_variable>
		
bool readySel=false;
bool processedSel = false;
std::mutex selMutex;
std::condition_variable cv;
using Ms = std::chrono::milliseconds;
namespace Wt {
    


class WCodeMirrorTextArea : public WContainerWidget 
{
private:
    std::string selectedText_;
    
public:
    JSignal<int> gutterClick_;
    JSignal<std::string> selTextSignal_;
    WTextArea * textArea_;
    
    WCodeMirrorTextArea () 
        : WContainerWidget (),gutterClick_(this,"gutterClick")
    ,selTextSignal_(this,"selTextSignal")
    {
        
    textArea_ = addNew<WTextArea>();
    
    //TODO:
    //We save the editor state to the text area on each key stroke,
    //it appears to be not a performance issue,
    //however it might very well become one when editing larger fragments of code.
    //A better solution would be to save this state to the text area only when
    //the form is submitted, currently this is not yet possible in Wt???.

    using std::string;
    
    string js =
        "var e = " + textArea_->jsRef() + ";" +
        "var cm = CodeMirror.fromTextArea(e, {" +
        //"    onKeyEvent : function (editor, event) {" +
        //"        editor.save();" +
        //"    }," +
        "    mode: 'text/x-c++src'," +
        "    lineNumbers: true, " +
        "    gutters: [\"CodeMirror-linenumbers\"]," + //, \"breakpoints\"], " +
        "    styleActiveLine: true," +
        //"    readOnly: true," +
        //"    value: \"var v1; function f2 (p1, p2, p3) { var v2; }\" " +
        "    });" +
        " cm.on(\"change\",function(editor,change) { editor.save();});"
        "var self = " + this->jsRef() + ";" +
        "self.cm = cm;";

    this->doJavaScript(js);
    /*
    std::stringstream jsGutter ;
        jsGutter     << "var self = " << jsRef() <<  ";" 
         << "self.cm.on(\"gutterClick\", function(cm, n) {" 
         << "var info = cm.lineInfo(n);"
         << "info.gutterMarkers ? cm.removeLineClass(n,\"background\") : cm.addLineClass(n,\"background\",\"breakpointline\");"
         << "cm.setGutterMarker(n, \"breakpoints\", info.gutterMarkers ? null : makeMarker());"
                << gutterClick_.createCall({"n"})
         << "});"

         << "function makeMarker() {"
         << "var marker = document.createElement(\"div\");"
         << "marker.style.color = \"#822\";"
         << "marker.style.fontSize = \"1.1em\";"
         << "marker.innerHTML = \"●\";"
         << "return marker;"
         << "}";
    this->doJavaScript(jsGutter.str());
     */
    selTextSignal_.connect(this, &WCodeMirrorTextArea::selTextUnlocker);
    }
    
    void setText(std::string text)
    {
        //textArea_->setText(text);  //Does this work after Codemirror is created??
        WString wtext(text);
        std::string js=  "var self = " + jsRef() +  ";" + "self.cm.setValue("+wtext.jsStringLiteral()+");";
        doJavaScript(js);
    }

    std::string getText() 
    {
        return textArea_-> text().toUTF8();
    }
    
    void updatewatchValues(int value)
    {
        std::stringstream js;
        Wt::WString varname1 = "@var1";
        Wt::WString varname2 = "@var2";
        Wt::WString value1 = "6'6";
        Wt::WString value2 = "7'7";
        js << "var self = " << jsRef() << ";"
                << "var varmap = new Object();"
                << "varmap['" << varname1 << "'] = " << value1.jsStringLiteral() << ";"
                << "varmap['" << varname2 << "'] = " << value2.jsStringLiteral() << ";"
                << "var iValue = " << value << ";"
                << "var spans = self.getElementsByTagName('span');"
                << "for (var i = 0; i < spans.length; i++) {"
                << "    if (spans[i].className == 'cm-variable-2') {"
                << "      if (varmap.hasOwnProperty(spans[i].innerHTML)){"
                << "        spans[i].title = spans[i].innerHTML + ' = ' + varmap[spans[i].innerHTML];"
                << "      }"        
                << "    }"
                << "}";
        std::string test = js.str();
   this->doJavaScript(js.str());
    }

    void setMarker(int line, std::string htmlMarker) 
    {
        std::stringstream js ;
        js     << "var self = " << jsRef() <<  ";" 
            <<  "self.cm.setGutterMarker("<<line << ", \"breakpoints\", makeMarker());" 
                << "cm.addLineClass("<<line << ",\"background\",\"breakpointline\");";
        
        this->doJavaScript(js.str());
    }

    void clearMarker(int line)
    {
        //doesn't work
        std::stringstream js ;
        js     << "var self = " <<  jsRef() << ";" 
            << "self.cm.clearMarker(" << line << ");";

        this->doJavaScript(js.str());
    }
     

    void signalSelectedText()
    {
        //doesn't work
        std::stringstream js ;
        js     << "var self = " <<  jsRef() << ";" 
            << "var selText = self.cm.getSelection();"
                << selTextSignal_.createCall({"selText"})
                << std::endl;
        
        //std::cout << "lock before doing javascript" << std::endl;
        this->doJavaScript(js.str());
        /*{
            std::lock_guard<std::mutex> lk(selMutex);
            readySel = true;
        }
        cv.notify_one();
        // wait for the selTextUnlocker function
        {
            std::unique_lock<std::mutex> lk(selMutex);
            cv.wait_for(lk, Ms(10000),[]{return processedSel;});
        }*/
        
    }
    std::string getSelectedText()
    {
        
        return selectedText_;
        
    };
    void selTextUnlocker(const std::string& selText)
    {
        /*
        std::unique_lock<std::mutex> lk(selMutex);
        cv.wait_for(lk, Ms(10000),[]{return readySel;});
        */
        selectedText_ = selText;
        
        //std::cout << "unlocked" << std::endl;
        
       // processedSel = true;
        //lk.unlock();
        //cv.notify_one();
    }
};

}
#endif /*  WT_WCodeMirrorTextArea */

