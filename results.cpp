#include <fstream>
#include <string>
#include <vector>
#include <iostream>
#include <set>
#include <tuple>
#include <algorithm>
#include <string.h>
#include <iomanip>

#define MIN_DIMENSION 8
#define MAX_DIMENSION 100

using namespace std;

class FileInfo {
    string variable;
    string value;
    string order;

    vector<pair<int, int>> labelingTimes;
    vector<pair<int, int>> constraintsTimes;
    vector<pair<int, int>> backtracks;

public:
    FileInfo(string variable, string value, string order){
        this->variable = variable;
        this->value = value;
        this->order = order;
    }

    string getVariable() const {
        return variable;
    }

    string getValue() const {
        return value;
    }

    string getOrder() const {
        return order;
    }

    bool operator==(const FileInfo& f) const {
        if(this->variable != f.getVariable())
            return false;
        if(this->value != f.getValue())
            return false;
        if(this->order != f.getOrder())
            return false;
        return true;
    }

    bool operator<(const FileInfo& f) const {
        if(this->variable < f.getVariable())
            return true;
        if(this->variable == f.getVariable()){
            if(this->value < f.getValue())
                return true;
            if(this->value == f.getValue()){
                if(this->order < f.getOrder())
                    return true;
            }
        }
        return false;
    }


    void addLabelingTime(int size, int time){
        this->labelingTimes.push_back(make_pair(size, time));
    }

    void addConstraintsTime(int size, int time){
        this->constraintsTimes.push_back(make_pair(size, time));
    }

    void addBacktracks(int size, int backtracks){
        this->backtracks.push_back(make_pair(size, backtracks));
    }

    vector<pair<int, int>> getLabelingTimes() const{
        return this->labelingTimes;
    }

    vector<pair<int, int>> getConstraintsTimes() const {
        return this->constraintsTimes;
    }

    vector<pair<int, int>> getBacktracks() const {
        return this->backtracks;
    }
};

class FileInfoHashFunction { 
public: 
    size_t operator()(const FileInfo* f) const
    { 
        hash<string> hasher;
        return hasher(f->getVariable() + f->getValue() + f->getOrder());   
    } 
}; 

class FileInfoComparator {
public: 
    bool operator()(const FileInfo* f1, const FileInfo* f2) const{
        if(f1->getVariable() < f2->getVariable())
            return true;
        if(f1->getVariable() == f2->getVariable()){
            if(f1->getValue() < f2->getValue())
                return true;
            if(f1->getValue() == f2->getValue()){
                if(f1->getOrder() < f2->getOrder())
                    return true;
            }
        }
        return false;
    }
};

typedef enum  {
    LABELING,
    CONSTRAINTS,
    BACKTRACKS
} graphType;

vector<string> colors = {
    "red", "green", "blue", "cyan", "magenta", "yellow", 
    "black", "gray", "darkgray", "lightgray", 
    "brown", "lime", "olive", "orange", "pink", "purple", 
    "teal", "violet"
};

vector<string> marks = {"circle", "square"};

/**
 * Functions to write tikzpictures graphs
 */
void beginGraph(ofstream &f, graphType type);
void endGraph(ofstream &f);
void addPlotOptions(ofstream &f, string color, string mark);
void addPair(ofstream &f, int first, double second);
void addLegendEntry(ofstream &f, string variable, string value, string order);
void writeGraphs(set<FileInfo*, FileInfoComparator> &fileInfo);


void writeTable(set<FileInfo*, FileInfoComparator> &fileInfo);
void writeTableRow(ofstream & f, vector<pair<int, int>> labelingTimes, vector<pair<int, int>> constraintTimes, vector<pair<int, int>> backtracks);

int main(int argc, char* argv[]){
    if(argc < 2){
        cout << "Error: Missing arguments!" << endl;
        cout << "results -g|-t" << endl;
        cout << "\t-g: creates the tikzpicture latex graphs" << endl;
        cout << "\t-t: creates the tabular latex table" << endl;

        return -1;
    }

    ifstream f("output.txt");

    string line;
    vector<string> outputInfo;

    while(!f.eof()){
        getline(f, line);
        string file_name = line.substr(6, 9);
        if(file_name == "dimension")
            outputInfo.push_back(line);
    }

    f.close();

    set<FileInfo*, FileInfoComparator> fileInfo;
    
    // Create set with information about each tuple of labeling options
    for(size_t i = 0; i < outputInfo.size(); i++){
        line = outputInfo[i];
        size_t dotPos = line.find("."); 
        int fileSize = stoi(line.substr(16, dotPos-16)); 
        if(fileSize > MAX_DIMENSION || fileSize < MIN_DIMENSION)
            continue;

        line = line.substr(line.find("-")+2);

        string variable = line.substr(0, line.find(" "));

        /*if(variable == "leftmost"){ // Delete leftmost from the graph 
            continue;
        }*/

        line = line.substr(line.find("-")+2);

        string value = line.substr(0, line.find(" "));
        line = line.substr(line.find("-")+2);
        
        /*if(value == "enum"){  // Delete enum from the graph 
            continue;
        }*/

        string order = line.substr(0, line.find(" "));
        line = line.substr(line.find(":")+2);

        int labelingTime = stoi(line.substr(0, line.find("ms")));
        line = line.substr(line.find(":")+2);

        int constraintsTime = stoi(line.substr(0, line.find("ms")));
        line = line.substr(line.find(":")+2);

        int backtracks = stoi(line);

        FileInfo* newFileInfo = new FileInfo(variable, value, order);

        set<FileInfo*, FileInfoComparator>::iterator it = fileInfo.find(newFileInfo);
        if(it != fileInfo.end()){
            (*it)->addLabelingTime(fileSize, labelingTime);
            (*it)->addConstraintsTime(fileSize, constraintsTime);
            (*it)->addBacktracks(fileSize, backtracks);
        }else{
            newFileInfo->addLabelingTime(fileSize, labelingTime);
            newFileInfo->addConstraintsTime(fileSize, constraintsTime);
            newFileInfo->addBacktracks(fileSize, backtracks);
            fileInfo.insert(newFileInfo);
        }
    }

    if(strcmp(argv[1], "-g") == 0){
        cout << "Creating graphs..." << endl;
        writeGraphs(fileInfo);
    }
    else if(strcmp(argv[1], "-t") == 0){
        cout << "Creating table..." << endl;
        writeTable(fileInfo);
    }else{
        cout << "Error: Unknown option!" << endl;
        return -1;
    }

    return 0;
}

bool vectorPairComp(pair<int, int> i, pair<int, int> j) { return (i.first<j.first); }

void writeTable(set<FileInfo*, FileInfoComparator> &fileInfo){
    ofstream f("latex_table/table.txt");

    f << setprecision(2);

    f << "\\begin{table}" << endl;
    f << "\\centering" << endl;
    f << "\\begin{tabular}{ p{3.5em} p{3em} p{2.5em} || p{2.5em} | p{2.5em} | p{2.5em} | p{2.5em} | p{2.5em} | p{2.5em} | p{2.5em} | p{2.5em} | p{2.5em}}" << endl; 
    f << "\\multicolumn{3}{c||}{Variables} & \\multicolumn{9}{c}{Dimensions} \\\\ [1ex]" << endl;
    f << "\\hline" << endl;
    f << "VAR & VAL & ORD & 8 & 9 & 10 & 11 & 12 & 25 & 50 & 75 & 100 \\\\ [1ex]" << endl;
    //f << "& & & LT & CT & NB & LT & CT & NB & LT & CT & NB & LT & CT & NB \\\\ [1ex]" << endl;
    f << "\\hline\\hline" << endl;

    vector<pair<int, int>> labelingTimes;
    vector<pair<int, int>> constraintTimes;
    vector<pair<int, int>> backtracks;

    for(auto it = fileInfo.begin(); it != fileInfo.end(); it++){
        f << (*it)->getVariable() << " & " << (*it)->getValue() << " & " << (*it)->getOrder() << " & ";
        
        labelingTimes = (*it)->getLabelingTimes();
        constraintTimes = (*it)->getConstraintsTimes();
        backtracks = (*it)->getBacktracks();

        sort(labelingTimes.begin(), labelingTimes.end(), vectorPairComp);
        sort(constraintTimes.begin(), constraintTimes.end(), vectorPairComp);
        sort(backtracks.begin(), backtracks.end(), vectorPairComp);

        writeTableRow(f, labelingTimes, constraintTimes, backtracks);
    }
    f << "\\hline" << endl;
    f << "\\end{tabular}" << endl;
    f << "\t\\caption{}" << endl;
    f << "\t\\label{tab:my_label}" << endl;
    f << "\\end{table}" << endl;

    f.close();
}

void writeTableRow(ofstream & f, vector<pair<int, int>> labelingTimes, vector<pair<int, int>> constraintTimes, vector<pair<int, int>> backtracks){
    int i = 0; 
    f << (labelingTimes[i].second+labelingTimes[i+1].second+labelingTimes[i+2].second)/3000.0 << " & "; 
    /*f << (constraintTimes[0].second+constraintTimes[1].second+constraintTimes[2].second)/3000.0 << " & "; 
    f << (backtracks[0].second+backtracks[1].second+backtracks[2].second)/3.0 << " & ";                 
    */
    f << (labelingTimes[i+3].second+labelingTimes[i+4].second+labelingTimes[i+5].second)/3000.0 << " & "; 
   /* f << (constraintTimes[3].second+constraintTimes[4].second+constraintTimes[5].second)/3000.0 << " & "; 
    f << (backtracks[3].second+backtracks[4].second+backtracks[5].second)/3.0 << " & ";
*/
    f << (labelingTimes[i+6].second+labelingTimes[i+7].second+labelingTimes[i+8].second)/3000.0 << " & "; 
   /* f << (constraintTimes[6].second+constraintTimes[7].second+constraintTimes[8].second)/3000.0 << " & "; 
    f << (backtracks[6].second+backtracks[7].second+backtracks[8].second)/3.0 << " & ";
*/
    f << (labelingTimes[i+9].second+labelingTimes[i+10].second+labelingTimes[i+11].second)/3000.0 << "&";
   /* f << (constraintTimes[9].second+constraintTimes[10].second+constraintTimes[11].second)/3000.0 << "&"; 
    f << (backtracks[9].second+backtracks[10].second+backtracks[11].second)/3.0 << "\\\\" << endl;
*/

    f << (labelingTimes[i+12].second+labelingTimes[i+13].second+labelingTimes[i+14].second)/3000.0 << " & "; 

    
    f << (labelingTimes[i+15].second+labelingTimes[i+16].second+labelingTimes[i+17].second)/3000.0 << " & "; 
    
    f << (labelingTimes[i+18].second+labelingTimes[i+19].second+labelingTimes[i+20].second)/3000.0 << " & "; 
    
    f << (labelingTimes[i+21].second+labelingTimes[i+22].second+labelingTimes[i+23].second)/3000.0 << " & "; 
    
    f << (labelingTimes[i+24].second+labelingTimes[i+25].second+labelingTimes[i+26].second)/3000.0 << "\\\\" << endl; 

    //f << "\\hline" << endl;
}

void writeGraphs(set<FileInfo*, FileInfoComparator> &fileInfo){
    ofstream f1("labelingTimes_complete.txt");
    ofstream f2("constraintsTimes_complete.txt");
    ofstream f3("backtracks_without_complete.txt");

    size_t color_index = 0;

    beginGraph(f1, LABELING);
    beginGraph(f2, CONSTRAINTS);
    beginGraph(f3, BACKTRACKS);

    for(auto it = fileInfo.begin(); it != fileInfo.end(); it++){
        addPlotOptions(f1, colors[color_index%colors.size()], marks[(color_index/colors.size())%marks.size()]);
        addPlotOptions(f2, colors[color_index%colors.size()], marks[(color_index/colors.size())%marks.size()]);
        addPlotOptions(f3, colors[color_index%colors.size()], marks[(color_index/colors.size())%marks.size()]);

        vector<pair<int, int>> labelingTimes = (*it)->getLabelingTimes();
        vector<pair<int, int>> constraintTimes = (*it)->getConstraintsTimes();
        vector<pair<int, int>> backtracks = (*it)->getBacktracks();  

        for(size_t i = 0; i < labelingTimes.size(); i+=3){
            addPair(f1, labelingTimes[i].first, (labelingTimes[i].second+labelingTimes[i+1].second+labelingTimes[i+2].second)/3000.0);
            addPair(f2, constraintTimes[i].first, (constraintTimes[i].second+constraintTimes[i+1].second+constraintTimes[i+2].second)/3000.0);
            addPair(f3, backtracks[i].first, (backtracks[i].second+backtracks[i+1].second+backtracks[i+2].second)/3.0);
        }

        addLegendEntry(f1, (*it)->getVariable(), (*it)->getValue(), (*it)->getOrder());
        addLegendEntry(f2, (*it)->getVariable(), (*it)->getValue(), (*it)->getOrder());
        addLegendEntry(f3, (*it)->getVariable(), (*it)->getValue(), (*it)->getOrder());

        color_index++;
    }

    endGraph(f1);
    endGraph(f2);
    endGraph(f3);

    f1.close();
    f2.close();
    f3.close();
}

void beginGraph(ofstream &f, graphType type){
    f << "\\begin{tikzpicture}" << endl;
    f << "\\begin{axis}[" << endl;
    f << "\taxis lines = left," << endl;
    f << "\txlabel = {Dimension $x*x$}," << endl;
    if(type == LABELING || type == CONSTRAINTS){
        f << "\tylabel = {Time (s)}," << endl;
    }else{
        f << "\tylabel = {Number of Backtracks}," << endl;
    }
    f << "\tlegend columns=4, " << endl;
    f << "\tlegend style={at={(0.5,-0.2)},anchor=north}," << endl;
    f << "\tenlarge x limits=-1, %hack to plot on the full x-axis scale" << endl;
    f << "\twidth=11cm, %set bigger width" << endl;
    f << "\theight=10cm," << endl;
    f << "]" << endl;
}

void endGraph(ofstream &f){
    f << "\\end{axis}" << endl;
    f << "\\end{tikzpicture}" << endl;
}

void addPlotOptions(ofstream &f, string color, string mark){
    f << "\\addplot[" << endl;
    f << "\tcolor=" << color << "," << endl;
    f << "\tmark=" << mark << "," << endl;
    f << "\t]" << endl;
    f << "\tcoordinates {" << endl << "\t";
}

void addPair(ofstream &f, int first, double second){
    f << "(" << first << "," << second << ")";
}

void addLegendEntry(ofstream &f, string variable, string value, string order){
    f << "};" << endl;
    f << "\\addlegendentry{" << variable << "$," << value << "$," << order << "}" << endl;
}