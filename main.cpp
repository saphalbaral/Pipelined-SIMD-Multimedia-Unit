#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
#include <map>
#include <bitset>
#include <algorithm>
using namespace std;

// converts "R5" or "5" to "00101"
string regToBin(string reg) {
    // Remove 'R', 'r', or ',' if present
    string clean = "";
    for (char c : reg) {
        if (isdigit(c)) {
            clean += c;
        }
    }
    if (clean.empty()) {
        return "00000";
    }

    int val = stoi(clean);
    return bitset<5>(val).to_string();
}

// converts immediate integers to 16 bit binary
string immToBin(string imm) {
    // remove ',' if present
    string clean = "";
    for (char c : imm) {
        if (isdigit(c) || c == '-') clean += c;
    }
    int val = stoi(clean);
    return bitset<16>(val).to_string();
}

// converts Load Index (0-7) to 3 bit binary
string indexToBin(string idx) {
    string clean = "";
    for (char c : idx) {
        if (isdigit(c)) clean += c;
    }
    int val = stoi(clean);
    return bitset<3>(val).to_string();
}


int main() {
    ifstream infile("assembly.txt");
    ofstream outfile("program.txt");

    if (!infile.is_open()) {
        cerr << "Error: Could not open assembly.txt" << endl;
        return 1;
    }

    // map for R3 opcodes
    // assuming xxxx are 0000.
    map<string, string> r3_opcodes = {
        {"nop",   "00000000"}, // xxxx0000
        {"shrhi", "00000001"}, // xxxx0001
        {"au",    "00000010"}, // xxxx0010
        {"cnt1h", "00000011"}, // xxxx0011
        {"ahs",   "00000100"}, // xxxx0100
        {"or",    "00000101"}, // xxxx0101
        {"bcw",   "00000110"}, // xxxx0110
        {"maxws", "00000111"}, // xxxx0111
        {"minws", "00001000"}, // xxxx1000
        {"mlhu",  "00001001"}, // xxxx1001
        {"mlhcu", "00001010"}, // xxxx1010
        {"and",   "00001011"}, // xxxx1011
        {"clzw",  "00001100"}, // xxxx1100
        {"rotw",  "00001101"}, // xxxx1101
        {"sfwu",  "00001110"}, // xxxx1110
        {"sfhs",  "00001111"}  // xxxx1111
    };

    // map for R4 opcodes
    // mnemonics simplified
    map<string, string> r4_funcs = {
        {"simal", "000"}, // Signed Integer Multiply-Add Low
        {"simah", "001"}, // Signed Integer Multiply-Add High
        {"simsl", "010"}, // Signed Integer Multiply-Sub Low
        {"simsh", "011"}, // Signed Integer Multiply-Sub High
        {"slmal", "100"}, // Signed Long Multiply-Add Low
        {"slmah", "101"}, // Signed Long Multiply-Add High
        {"slmsl", "110"}, // Signed Long Multiply-Sub Low
        {"slmsh", "111"}  // Signed Long Multiply-Sub High
    };

    string line;
    while (getline(infile, line)) {
        stringstream ss(line);
        string opcode;
        ss >> opcode;

        // convert opcode to lowercase for matching
        transform(opcode.begin(), opcode.end(), opcode.begin(), ::tolower);

        string binary_out = "";

        // handle nop (special case for R3)
        if (opcode == "nop") {
            // 11 + 00000000 + 00000 + 00000 + 00000
            binary_out = "1100000000000000000000000";
        }

        // handle R4 format
        // syntax: li rd, load_index, immediate
        else if (opcode == "li") {
            string rd_str, idx_str, imm_str;
            ss >> rd_str >> idx_str >> imm_str;

            // 0 (1) + Index (3) + Imm (16) + Rd (5) = total 25 bits
            binary_out = "0" + indexToBin(idx_str) + immToBin(imm_str) + regToBin(rd_str);
        }

        // handle R4 format (3 Sources)
        // syntax: opcode rd, rs1, rs2, rs3
        else if (r4_funcs.find(opcode) != r4_funcs.end()) {
            string rd_str, rs1_str, rs2_str, rs3_str;
            ss >> rd_str >> rs1_str >> rs2_str >> rs3_str;

            // 10 (2) + Func (3) + Rs3 (5) + Rs2 (5) + Rs1 (5) + Rd (5) = 25 bits
            binary_out = "10" + r4_funcs[opcode] + regToBin(rs3_str) + regToBin(rs2_str) + regToBin(rs1_str) + regToBin(rd_str);
        }

        // handle R3 format (2 Sources)
        // syntax: opcode rd, rs1, rs2
        else if (r3_opcodes.find(opcode) != r3_opcodes.end()) {
            string rd_str, rs1_str, rs2_str;
            ss >> rd_str >> rs1_str >> rs2_str;

            // 11 (2) + Opcode (8) + Rs2 (5) + Rs1 (5) + Rd (5)
            binary_out = "11" + r3_opcodes[opcode] + regToBin(rs2_str) + regToBin(rs1_str) + regToBin(rd_str);
        }

        if (!binary_out.empty()) {
            outfile << binary_out << endl;
            // for debugging
            // cout << "Assembled " << opcode << " -> " << binary_out << endl;
        }
    }

    cout << "Assembly completed. Outputs written to program.txt." << endl;
    infile.close();
    outfile.close();
    return 0;
}