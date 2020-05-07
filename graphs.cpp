#include <fstream>
#include <string>
#include <vector>
#include <iostream>
#include <unordered_set>
#include <tuple>

#define MIN_DIMENSION 25
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
        if(f1->getVariable() != f2->getVariable())
            return false;
        if(f1->getValue() != f2->getValue())
            return false;
        if(f1->getOrder() != f2->getOrder())
            return false;
        return true;
    }
};

int main(){
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

    unordered_set<FileInfo*, FileInfoHashFunction, FileInfoComparator> fileInfo;
    
    // Create set with information about each tuple of labeling options
    for(size_t i = 0; i < outputInfo.size(); i++){
        line = outputInfo[i];
        size_t dotPos = line.find("."); 
        int fileSize = stoi(line.substr(16, dotPos-16)); 
        if(fileSize > MAX_DIMENSION || fileSize < MIN_DIMENSION)
            continue;

        line = line.substr(line.find("-")+2);

        string variable = line.substr(0, line.find(" "));

        if(variable == "leftmost"){ // Delete leftmost from the graph 
            continue;
        }

        line = line.substr(line.find("-")+2);

        string value = line.substr(0, line.find(" "));
        line = line.substr(line.find("-")+2);
        
        if(value == "enum"){  // Delete enum from the graph 
            continue;
        }

        string order = line.substr(0, line.find(" "));
        line = line.substr(line.find(":")+2);

        int labelingTime = stoi(line.substr(0, line.find("ms")));
        line = line.substr(line.find(":")+2);

        int constraintsTime = stoi(line.substr(0, line.find("ms")));
        line = line.substr(line.find(":")+2);

        int backtracks = stoi(line);

        FileInfo* newFileInfo = new FileInfo(variable, value, order);

        unordered_set<FileInfo*, FileInfoHashFunction, FileInfoComparator>::iterator it = fileInfo.find(newFileInfo);
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

    ofstream f1("labelingTimes.txt");
    ofstream f2("constraintsTimes.txt");
    ofstream f3("backtracks.txt");

    vector<string> colors = {
        "red", "green", "blue", "cyan", "magenta", "yellow", 
        "black", "gray", "darkgray", "lightgray", 
        "brown", "lime", "olive", "orange", "pink", "purple", 
        "teal", "violet"
    };

    vector<string> marks = {"circle", "square"};

    size_t color_index = 0;
    for(auto it = fileInfo.begin(); it != fileInfo.end(); it++){
        f1 << "\\addplot[" << endl;
        f2 << "\\addplot[" << endl;
        f3 << "\\addplot[" << endl;
        f1 << "\tcolor=" << colors[color_index%colors.size()] << "," << endl;
        f2 << "\tcolor=" << colors[color_index%colors.size()] << "," << endl;
        f3 << "\tcolor=" << colors[color_index%colors.size()] << "," << endl;
        f1 << "\tmark=" << marks[(color_index/colors.size())%marks.size()] << "," << endl;
        f2 << "\tmark=" << marks[(color_index/colors.size())%marks.size()] << "," << endl;
        f3 << "\tmark=" << marks[(color_index/colors.size())%marks.size()] << "," << endl;
        f1 << "\t]" << endl;
        f2 << "\t]" << endl;
        f3 << "\t]" << endl;
        f1 << "\tcoordinates {" << endl << "\t";
        f2 << "\tcoordinates {" << endl << "\t";
        f3 << "\tcoordinates {" << endl << "\t";

        vector<pair<int, int>> labelingTimes = (*it)->getLabelingTimes();
        vector<pair<int, int>> constraintTimes = (*it)->getConstraintsTimes();
        vector<pair<int, int>> backtracks = (*it)->getBacktracks();  

        for(size_t i = 0; i < labelingTimes.size(); i+=3){
            f1 << "(" << labelingTimes[i].first << "," << (labelingTimes[i].second+labelingTimes[i+1].second+labelingTimes[i+2].second)/3000.0 << ")";
            f2 << "(" << constraintTimes[i].first << "," << (constraintTimes[i].second+constraintTimes[i+1].second+constraintTimes[i+2].second)/3000.0 << ")";
            f3 << "(" << backtracks[i].first << "," << (backtracks[i].second+backtracks[i+1].second+backtracks[i+2].second)/3.0 << ")";
        }

        f1 << "};" << endl;
        f2 << "};" << endl;
        f3 << "};" << endl;

        f1 << "\\addlegendentry{" << (*it)->getVariable() << "$," << (*it)->getValue() << "$," << (*it)->getOrder() << "}" << endl;
        f2 << "\\addlegendentry{" << (*it)->getVariable() << "$," << (*it)->getValue() << "$," << (*it)->getOrder() << "}" << endl;
        f3 << "\\addlegendentry{" << (*it)->getVariable() << "$," << (*it)->getValue() << "$," << (*it)->getOrder() << "}" << endl;

        color_index++;
    }

    f1.close();
    f2.close();
    f3.close();

    return 0;
}