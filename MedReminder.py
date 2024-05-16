import time
from datetime import datetime, timedelta
import pandas as pd

medication_dataset = pd.read_csv(r'C:\Users\Acer\Desktop\medicine_dataset.csv')

users = {}

def register_user():
    print("\n--- Register New User ---")
    name = input("Please enter your name: ")
    age = input("Please enter your age: ")
    if name in users:
        print(f"Welcome back, {name}!")
        return name
    users[name] = {'name': name, 'age': age, 'medications': []}
    print(f"User {name} registered successfully!\n")
    return name

def add_medication(user):
    print("\n--- Add Medication ---")
    med_name = input("Enter the name of the medicine: ")
    total_pills = int(input("How many pills do you have in total? "))
    pills_per_dose = int(input("How many pills per dose? "))
    interval_hours = int(input("How many hours between doses? "))
    next_dose_time = datetime.now() + timedelta(hours=interval_hours)

    medication = {
        'name': med_name,
        'original_total_pills': total_pills,  # Store original total for history
        'total_pills': total_pills,
        'pills_per_dose': pills_per_dose,
        'next_dose_time': next_dose_time,
        'dose_taken': 0  # Track the total number of pills taken
    }
    users[user]['medications'].append(medication)
    print(f"Medication {med_name} added successfully!\n")

def show_schedule(user):
    print("\n--- Current Medication Schedule ---")
    for med in users[user]['medications']:
        next_dose_str = med['next_dose_time'].strftime("%Y-%m-%d %H:%M:%S")
        pills_left = med['total_pills']
        warning_msg = " (Warning: Low on medication!)" if pills_left <= 3 else ""
        print(f"{med['name']} - Next dose: {next_dose_str} - Pills taken: {med['dose_taken']} - Pills left: {pills_left}{warning_msg}")

def take_pills(user):
    show_schedule(user)
    med_name = input("Enter the name of the medicine you are taking: ")
    for med in users[user]['medications']:
        if med['name'].lower() == med_name.lower():
            if med['total_pills'] >= med['pills_per_dose']:
                med['total_pills'] -= med['pills_per_dose']
                med['dose_taken'] += med['pills_per_dose']
                warning_msg = " (Warning: Low on medication!)" if med['total_pills'] <= 3 else ""
                print(f"You have taken {med['pills_per_dose']} pills of {med_name}. Pills left: {med['total_pills']}{warning_msg}")
            else:
                print(f"Not enough pills left to take a dose of {med_name}.")
            return
    print("Medication not found.")

def update_medication(user):
    print("\n--- Update Medication ---")
    med_name = input("Enter the name of the medicine you want to update: ")
    for med in users[user]['medications']:
        if med['name'].lower() == med_name.lower():
            total_pills = int(input("Enter the new total pills count: "))
            pills_per_dose = int(input("Enter the new pills per dose count: "))
            interval_hours = int(input("Enter the new interval hours: "))
            med['total_pills'] = total_pills
            med['pills_per_dose'] = pills_per_dose
            med['next_dose_time'] = datetime.now() + timedelta(hours=interval_hours)
            print(f"Medication {med_name} updated successfully!\n")
            return
    print("Medication not found.")

def delete_medication(user):
    print("\n--- Delete Medication ---")
    med_name = input("Enter the name of the medicine you want to delete: ")
    for med in users[user]['medications']:
        if med['name'].lower() == med_name.lower():
            users[user]['medications'].remove(med)
            print(f"Medication {med_name} deleted successfully!\n")
            return
    print("Medication not found.")

def main_menu(user):
    print("\n--- Main Menu ---")
    print("1. Register User or Login")
    print("2. Add Medication")
    print("3. Show Medication Schedule")
    print("4. Take Pills")
    print("5. Update Medication")
    print("6. Delete Medication")
    print("7. View Pills History")
    print("8. Show Side Effects")
    print("9. Exit")

    choice = input("Enter choice: ")
    return choice

def view_pills_history(user):
    print("\n--- Pills History ---")
    for med in users[user]['medications']:
        original_total = med['original_total_pills']
        pills_taken = med['dose_taken']
        pills_left = med['total_pills']
        print(f"{med['name']} - Original Total Pills: {original_total}, Total Pills Taken: {pills_taken}, Pills Left: {pills_left}")

def display_side_effects(med_name):
    med_info = medication_dataset[medication_dataset['name'].str.lower() == med_name.lower()]
    if not med_info.empty:
        print(f"The side effects of {med_name} are:")
        side_effects = []
        for i in range(1, 15):
            side_effect = med_info[f'sideEffect{i}'].iloc[0]
            if not pd.isna(side_effect):
                side_effects.append(side_effect)
        if side_effects:
            for i, side_effect in enumerate(side_effects, start=1):
                print(f"{i}. {side_effect}")
        else:
            print("No side effects listed.")
    else:
        print("Medication not found in the dataset.")


def main():
    current_user = None
    while True:
        choice = main_menu(current_user)
        if choice == '1':
            current_user = register_user()
        elif choice == '2':
            if current_user:
                add_medication(current_user)
            else:
                print("Please register a user first!")
        elif choice == '3':
            if current_user:
                show_schedule(current_user)
            else:
                print("No user registered!")
        elif choice == '4':
            if current_user:
                take_pills(current_user)
            else:
                print("No user registered or medication added!")
        elif choice == '5':
            if current_user:
                update_medication(current_user)
            else:
                print("No user registered or medication added!")
        elif choice == '6':
            if current_user:
                delete_medication(current_user)
            else:
                print("No user registered or medication added!")
        elif choice == '7':
            if current_user:
                view_pills_history(current_user)
            else:
                print("No user registered or medication added!")
        elif choice == '8':
            if current_user:
                med_name = input("Enter the name of the medicine: ")
                display_side_effects(med_name)
            else:
                print("No user registered or medication added!")
        elif choice == '9':
            print("Exiting program.")
            break
        else:
            print("Invalid choice, please try again!")

if __name__ == "__main__":
    main()
