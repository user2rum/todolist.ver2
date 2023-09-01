//
//  toDoPageViewController.swift
//  todolist.ver2
//
//  Created by t2023-m0075 on 2023/08/25.
//

import UIKit

protocol SendingTodoData: AnyObject {
    func sendingTodoList(for section: Section, _ names: [String])
}

enum Section: Int, CaseIterable {
    case morning = 0
    case afternoon
    
    var title: String {
        switch self {
        case .morning:
            return "오전"
        case .afternoon:
            return "오후"
        }
    }
}

class toDoPageViewController: UIViewController {

    @IBOutlet weak var toDoTableView: UITableView!
    
    var task: [String] = []
    var toggleOnTask: [String] = []
    //섹션 배열 생성
    var sections: [Section: [String]] = [.morning: [], .afternoon: []]
    
    weak var sendingTodoData: SendingTodoData? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // xib 파일 등록
        let nib = UINib(nibName: "toDoPageTableViewCell", bundle: nil)
        toDoTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        toDoTableView.delegate = self
        toDoTableView.dataSource = self
        
        // 변경 3: 데이터를 먼저 로드한 후 테이블 뷰를 다시 로드합니다.
        
        loadData()
        toDoTableView.reloadData()

       
    }
    
    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "할 일 목록", message: "\n\n\n 할 일을 적어주세요.", preferredStyle: .alert)
        
        // 변경 4: 간소화된 코드 스타일
        alertController.addTextField { textField in
            textField.placeholder = "내용을 입력해주세요."
        }
        //섹션 종류 선택
        let segmentedControl = UISegmentedControl(items: ["오전", "오후"])
           segmentedControl.frame = CGRect(x: 20, y: 50, width: 230, height: 30)
           alertController.view.addSubview(segmentedControl)

        
        // 변경 6: 간소화된 조건문
        let saveAction = UIAlertAction(title: "저장", style: .default) { [unowned alertController, unowned segmentedControl] _ in
                if let textField = alertController.textFields?.first, let text = textField.text, !text.isEmpty {
                    // 선택된 섹션에 따라 데이터 저장
                    if segmentedControl.selectedSegmentIndex == 0 {
                        self.sections[.morning]?.append(text)
                    } else if segmentedControl.selectedSegmentIndex == 1 {
                        self.sections[.afternoon]?.append(text)
                    }
                    print(self.sections)
                    self.toDoTableView.reloadData()
                }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    
    }
    
}

extension toDoPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.task.count
        
        //섹션 나누기
        let sectionKey: Section = section == 0 ? .morning : .afternoon
           return sections[sectionKey]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //섹션
        let sectionKey: Section = indexPath.section == 0 ? .morning : .afternoon
        if let sectionData = sections[sectionKey] {
            cell.textLabel?.text = sectionData[indexPath.row]
            
        }
       // cell.textLabel?.text = task[indexPath.row]
        print("\(task) 투두 리스트 현황")
        
        // 변경 5: 스위치의 초기화를 간소화합니다.
        let switchView = UISwitch(frame: .zero)
        switchView.isOn = false
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        cell.accessoryView = switchView
        
        return cell
    }

    
    //섹션 생성
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "오전" : "오후"
    }


    
    @objc func switchValueChanged(_ sender: UISwitch) {
        guard let cell = sender.superview?.superview as? UITableViewCell,
              let indexPath = toDoTableView.indexPath(for: cell) else {
            return
        }

        let sectionKey: Section = indexPath.section == 0 ? .morning : .afternoon
        guard let sectionData = sections[sectionKey] else { return }

        let toggledTask = sectionData[indexPath.row]
        
        if sender.isOn {
            toggleOnTask.append(toggledTask)
            sections[sectionKey]?.remove(at: indexPath.row)
            sendingTodoData?.sendingTodoList(for: sectionKey, toggleOnTask)
            print("\(self.toggleOnTask) 던-투두 리스트 현황")
        } else {
            // 스위치를 꺼두었을 때의 로직
        }

        toDoTableView.reloadData()
    }
    
    // 변경 7: 삭제 로직을 수행하기 전에 editingStyle이 .delete인지 확인합니다. 드래그 해서 삭제
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
               let sectionKey: Section = indexPath.section == 0 ? .morning : .afternoon
               sections[sectionKey]?.remove(at: indexPath.row)
               toDoTableView.deleteRows(at: [indexPath], with: .automatic)
           }
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionKey: Section = indexPath.section == 0 ? .morning : .afternoon
           guard let sectionData = sections[sectionKey] else { return }
           
           let currentTask = sectionData[indexPath.row]

           let alertController = UIAlertController(title: "할 일 수정", message: nil, preferredStyle: .alert)
           alertController.addTextField { textField in
               textField.text = currentTask
           }
           
           let saveAction = UIAlertAction(title: "저장", style: .default) { [unowned alertController] _ in
               if let textField = alertController.textFields?.first, let text = textField.text, !text.isEmpty {
                   self.sections[sectionKey]?[indexPath.row] = text
                   self.toDoTableView.reloadData()
               }
           }
           
           let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
           
           alertController.addAction(saveAction)
           alertController.addAction(cancelAction)
           
           present(alertController, animated: true, completion: nil)
           
           toDoTableView.deselectRow(at: indexPath, animated: true)
       }

    
    func modifyTask(at index: Int, newTask: String) {
        if index >= 0 && index < task.count {
            task[index] = newTask
            saveData()
            toDoTableView.reloadData()
        } else {
            print("Invalid index: \(index)")
        }

    }
    /*  유                저                    디              폴                 트*/
    func saveData() {
        UserDefaults.standard.set(self.task, forKey: "tasks")
        UserDefaults.standard.set(self.toggleOnTask, forKey: "toggleOnTask")
    }
    
    func loadData() {
        if let savedTasks = UserDefaults.standard.array(forKey: "tasks") as? [String] {
            self.task = savedTasks
        }
        if let savedToggleOnTask = UserDefaults.standard.array(forKey: "toggleOnTask") as? [String] {
            self.toggleOnTask = savedToggleOnTask
        }
        
    }
    
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            saveData()
        }
}
