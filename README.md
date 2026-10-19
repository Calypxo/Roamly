# Roamly

**Plan your next trip and keep your travel budget in view.**

Roamly is a mobile travel planning and budget tracking app developed in **Android Studio with Flutter and Dart**. It brings trip details, personal and group budgets, expenses, and itineraries together so travelers can organize an adventure and keep track of its costs in one place.

## Key features

| Feature | What it does |
| --- | --- |
| **Home dashboard** | View planned trip totals, group budgets, personal spending, and recent trips, with quick access to trip creation. |
| **Trip management** | Create, edit, and delete trips with a name, destination, start and end dates, member count, notes, and a choice of illustrated covers. |
| **Personal and group budgets** | Set separate budgets for each trip and review group expense totals, estimated shares per member, and the remaining personal budget. Amounts are displayed in Philippine pesos (PHP). |
| **Expense tracking** | Add, edit, and delete personal or group expenses with an amount, date, and notes. Organize spending into Food, Transport, Stay, and Other categories. |
| **Itinerary planning** | Create, update, and remove activities with a title, location, date, time, and notes. View plans organized by date within each trip. |
| **Account access** | Register, sign in, view the traveler profile, and sign out through Firebase Authentication. |
| **Live data updates** | Trips, expenses, and itinerary records are stored in Cloud Firestore and displayed through live data streams for the signed-in user. |

## How the app fits together

1. **Create a trip** with its destination, dates, member count, and budgets.
2. **Plan the itinerary** by adding activities and places to visit.
3. **Record spending** as personal or group expenses.
4. **Review the budget** to see personal spending, remaining funds, and estimated group shares.

The main navigation connects **Home**, **Trips**, and **Profile**. Each trip opens a details page with access to its **Budget** and **Itinerary**.

## App preview

The dashboard, trip, budget, and itinerary previews below were captured from **Flutter web in a mobile-sized layout**, using sample trip and expense data.

<table>
  <tr>
    <th>Home dashboard</th>
    <th>Your trips</th>
    <th>Trip details</th>
  </tr>
  <tr>
    <td align="center"><img src="assets/readme/roamly_dashboard_web.png" alt="Roamly home dashboard with sample trip totals, group budgets, personal spending, and recent trips" width="230"></td>
    <td align="center"><img src="assets/readme/roamly_trips_web.png" alt="Roamly trip list showing sample Baguio and Pampanga trips" width="230"></td>
    <td align="center"><img src="assets/readme/roamly_trip_details_web.png" alt="Roamly trip details with destination, dates, budgets, member count, and planning options" width="230"></td>
  </tr>
  <tr>
    <th>Budget overview</th>
    <th>Trip itinerary</th>
    <th>Expense details</th>
  </tr>
  <tr>
    <td align="center"><img src="assets/readme/roamly_budget_web.png" alt="Roamly budget overview showing group costs, estimated member share, and personal budget" width="230"></td>
    <td align="center"><img src="assets/readme/roamly_itinerary_web.png" alt="Roamly itinerary with sample activities, locations, dates, and times" width="230"></td>
    <td align="center"><img src="assets/readme/roamly_expense_form_web.png" alt="Roamly expense form with a sample amount, category, expense type, date, and notes" width="230"></td>
  </tr>
</table>

<details>
<summary>View account screens and planning forms</summary>

<table>
  <tr>
    <th>Sign in</th>
    <th>Create an account</th>
  </tr>
  <tr>
    <td align="center"><img src="assets/readme/roamly_login.png" alt="Roamly sign-in screen with empty fields" width="230"></td>
    <td align="center"><img src="assets/readme/roamly_register.png" alt="Roamly registration screen with empty fields" width="230"></td>
  </tr>
  <tr>
    <th>Edit a trip</th>
    <th>Edit an activity</th>
  </tr>
  <tr>
    <td align="center"><img src="assets/readme/roamly_trip_form_web.png" alt="Roamly trip form with a sample destination, travel dates, budgets, and member count" width="230"></td>
    <td align="center"><img src="assets/readme/roamly_activity_form_web.png" alt="Roamly activity form with a sample title, location, time, date, and notes" width="230"></td>
  </tr>
</table>

</details>

## Built with

| Technology | Role |
| --- | --- |
| **Flutter and Dart** | Mobile interface and application logic |
| **Firebase Authentication** | Account registration, sign-in, and sign-out |
| **Cloud Firestore** | Trip, expense, and itinerary data |
| **Provider** | Application state management |
| **Android Studio** | Development environment |
