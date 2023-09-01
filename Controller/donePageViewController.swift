//
//  donePageViewController.swift
//  todolist.ver2
//
//  Created by t2023-m0075 on 2023/08/25.
//

import UIKit

enum Sections: Int, CaseIterable {
    case morning, afternoon
}

class donePageViewController: UIViewController ,SendingTodoData {
    
    func sendingTodoList(for section: Section, _ names: [String]) {
        toggleOnTask.append(contentsOf: names)

            // 섹션별로 데이터를 분류하는 로직 추가
            for name in names {
                if name.hasPrefix("오전: ") {
                    sections[.morning]?.append(name.replacingOccurrences(of: "오전: ", with: ""))
                } else if name.hasPrefix("오후: ") {
                    sections[.afternoon]?.append(name.replacingOccurrences(of: "오후: ", with: ""))
                }
            }
            
            saveToggleOnTask()
            doneTableView.reloadData()
    }
    

    @IBOutlet weak var doneTableView: UITableView!
    
    var toggleOnTask: [String] = []
    var sections: [Sections: [String]] = [
           .morning: [],
           .afternoon: []
       ]
    
    
    weak var sendingTodoData: SendingTodoData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // xib 파일 등록
        let nib = UINib(nibName: "donePageTableViewCell", bundle: nil)
        doneTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        doneTableView.delegate = self
        doneTableView.dataSource = self
        //loadToggleOnTask()
        
        //doneTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
           loadToggleOnTask() // 저장된 toggleOnTask 데이터 로드
        
    }
    
    func saveToggleOnTask() {
        UserDefaults.standard.set(toggleOnTask, forKey: "toggleOnTask")
    }
    
    func loadToggleOnTask() {
        if let savedToggleOnTask = UserDefaults.standard.array(forKey: "toggleOnTask") as? [String] {
            toggleOnTask = savedToggleOnTask
            doneTableView.reloadData()
            
        }
    }
}

extension donePageViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return Sections.allCases.count
        }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            guard let sectionKey = Section(rawValue: section) else { return nil }
            switch sectionKey {
            case .morning:
                return "오전"
            case .afternoon:
                return "오후"
            }
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionKey = Sections(rawValue: section) else {
               return 0
           }
           return sections[sectionKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        guard let sectionKey = Sections(rawValue: indexPath.section), let sectionData = sections[sectionKey] else {
                   return cell
               }
        cell.textLabel?.text = toggleOnTask[indexPath.row]
        return cell
    }
        
    // 셀 삭제 로직
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                    guard let sectionKey = Sections(rawValue: indexPath.section) else { return }
                    sections[sectionKey]?.remove(at: indexPath.row)
                    
                    // 2. 데이터를 저장합니다.
                    saveToggleOnTask()
                    
                    // 3. 테이블 뷰에서 셀 삭제
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
    }
