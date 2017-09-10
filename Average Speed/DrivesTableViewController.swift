//
//  DrivesTableViewController.swift
//  Average Speed
//
//  Created by Muhammed Nurkerim on 09/09/2017.
//  Copyright © 2017 Muhammed Nurkerim. All rights reserved.
//

import UIKit

class DrivesTableViewController: UITableViewController {

    var drives = [Drive]()
    var selectedDrive: Drive?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            try drives = CoreDataStack.context.fetch(Drive.fetchRequest())
        } catch {
            print(error)
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        print("View loaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return drives.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss"
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        
        let drive = drives[indexPath.row]
        let timestamp = drive.timestamp
        let formattedDuration = FormatDisplay.time(Int(drive.duration))
        let formattedDistance = FormatDisplay.distance(Measurement.init(value: drive.distance, unit: UnitLength.meters).value)
        
        cell.textLabel?.text = dateFormatter.string(from: timestamp! as Date)
        cell.detailTextLabel?.text = "Distance: \(formattedDistance) | Duration: \(formattedDuration)"

        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedDrive = drives[indexPath.row]
        print("Selecting drive at index \(indexPath.row)")

        return indexPath
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "CellToDetailView") {
            let destination = segue.destination as! DetailedViewController
            destination.drive = selectedDrive
        }
    }

}
