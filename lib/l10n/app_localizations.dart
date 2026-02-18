import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @india.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get india;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @mob_no.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mob_no;

  /// No description provided for @i_have_read.
  ///
  /// In en, this message translates to:
  /// **'I have read and agreed to '**
  String get i_have_read;

  /// No description provided for @terms_condition.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get terms_condition;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// No description provided for @i_have_read_hereby.
  ///
  /// In en, this message translates to:
  /// **'I have read and hereby provide my consent on the '**
  String get i_have_read_hereby;

  /// No description provided for @tds_declaration.
  ///
  /// In en, this message translates to:
  /// **'TDS Declaration'**
  String get tds_declaration;

  /// No description provided for @please_enter_valid_ten.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid 10-digit mobile number'**
  String get please_enter_valid_ten;

  /// No description provided for @please_agree_to_all.
  ///
  /// In en, this message translates to:
  /// **'Please agree to all terms and conditions to proceed'**
  String get please_agree_to_all;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @video_not_available.
  ///
  /// In en, this message translates to:
  /// **'Video not available'**
  String get video_not_available;

  /// No description provided for @watch_this_video.
  ///
  /// In en, this message translates to:
  /// **'Watch this video to learn how to register and accept rides\non the YoyoMiles Partner app.'**
  String get watch_this_video;

  /// No description provided for @watch_video.
  ///
  /// In en, this message translates to:
  /// **'Watch Video'**
  String get watch_video;

  /// No description provided for @otp.
  ///
  /// In en, this message translates to:
  /// **'One Time Password (OTP) has been sent to this number'**
  String get otp;

  /// No description provided for @enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enter_otp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'VERIFY'**
  String get verify;

  /// No description provided for @resend_otp.
  ///
  /// In en, this message translates to:
  /// **'RESEND OTP'**
  String get resend_otp;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @driver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driver;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enter_name.
  ///
  /// In en, this message translates to:
  /// **'Enter Name'**
  String get enter_name;

  /// No description provided for @upload_the_following.
  ///
  /// In en, this message translates to:
  /// **'Upload the following *'**
  String get upload_the_following;

  /// No description provided for @owner_aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Owner Aadhaar Card'**
  String get owner_aadhaar;

  /// No description provided for @owner_pan.
  ///
  /// In en, this message translates to:
  /// **'Owner PAN Card'**
  String get owner_pan;

  /// No description provided for @owner_selfie.
  ///
  /// In en, this message translates to:
  /// **'Owner Selfie'**
  String get owner_selfie;

  /// No description provided for @front_side.
  ///
  /// In en, this message translates to:
  /// **'Front Side'**
  String get front_side;

  /// No description provided for @back_side.
  ///
  /// In en, this message translates to:
  /// **'Back Side'**
  String get back_side;

  /// No description provided for @take_selfie.
  ///
  /// In en, this message translates to:
  /// **'Take Selfie'**
  String get take_selfie;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @please_enter_name.
  ///
  /// In en, this message translates to:
  /// **'Please Enter Name'**
  String get please_enter_name;

  /// No description provided for @please_upload_both_aadhaar.
  ///
  /// In en, this message translates to:
  /// **'Please upload both sides of Aadhaar card'**
  String get please_upload_both_aadhaar;

  /// No description provided for @please_upload_both_pan.
  ///
  /// In en, this message translates to:
  /// **'Please upload both sides of PAN card'**
  String get please_upload_both_pan;

  /// No description provided for @please_upload_selfie.
  ///
  /// In en, this message translates to:
  /// **'Please upload selfie'**
  String get please_upload_selfie;

  /// No description provided for @file_size_to_large.
  ///
  /// In en, this message translates to:
  /// **'File sizes too large. Please try with smaller images.'**
  String get file_size_to_large;

  /// No description provided for @server_error.
  ///
  /// In en, this message translates to:
  /// **'Server error:'**
  String get server_error;

  /// No description provided for @submission_failed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed:'**
  String get submission_failed;

  /// No description provided for @vehicle_detail.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Detail'**
  String get vehicle_detail;

  /// No description provided for @select_delivery_type.
  ///
  /// In en, this message translates to:
  /// **'Select Delivery Type'**
  String get select_delivery_type;

  /// No description provided for @parcel_delivery.
  ///
  /// In en, this message translates to:
  /// **'Parcel Delivery'**
  String get parcel_delivery;

  /// No description provided for @passenger_delivery.
  ///
  /// In en, this message translates to:
  /// **'Passenger Delivery'**
  String get passenger_delivery;

  /// No description provided for @no_vehicle_available.
  ///
  /// In en, this message translates to:
  /// **'No vehicles available'**
  String get no_vehicle_available;

  /// No description provided for @select_vehicle_type.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Type'**
  String get select_vehicle_type;

  /// No description provided for @no_parcel_delivery_vehicle.
  ///
  /// In en, this message translates to:
  /// **'No parcel delivery vehicles available'**
  String get no_parcel_delivery_vehicle;

  /// No description provided for @no_passenger_delivery_vehicle.
  ///
  /// In en, this message translates to:
  /// **'No passenger delivery vehicles available'**
  String get no_passenger_delivery_vehicle;

  /// No description provided for @select_vehicle_body_detail.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Body Detail'**
  String get select_vehicle_body_detail;

  /// No description provided for @select_vehicle_body_type.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Body Type'**
  String get select_vehicle_body_type;

  /// No description provided for @select_vehicle_fuel_type.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Fuel Type'**
  String get select_vehicle_fuel_type;

  /// No description provided for @no_fuel_type_available.
  ///
  /// In en, this message translates to:
  /// **'No fuel types available for this vehicle'**
  String get no_fuel_type_available;

  /// No description provided for @please_select_a_vehicle_type_first.
  ///
  /// In en, this message translates to:
  /// **'Please select a vehicle type first.'**
  String get please_select_a_vehicle_type_first;

  /// No description provided for @no_body_detail_available_for_this.
  ///
  /// In en, this message translates to:
  /// **'No body details available for this vehicle'**
  String get no_body_detail_available_for_this;

  /// No description provided for @no_fuel_type_avail.
  ///
  /// In en, this message translates to:
  /// **'No fuel types available for this vehicle.'**
  String get no_fuel_type_avail;

  /// No description provided for @vehicle_number.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number *'**
  String get vehicle_number;

  /// No description provided for @enter_vehicle_number.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Number'**
  String get enter_vehicle_number;

  /// No description provided for @vehicle_number_required.
  ///
  /// In en, this message translates to:
  /// **'Vehicle number is required'**
  String get vehicle_number_required;

  /// No description provided for @enter_valid_vehicle_number.
  ///
  /// In en, this message translates to:
  /// **'Enter valid vehicle number'**
  String get enter_valid_vehicle_number;

  /// No description provided for @select_city_of_operation.
  ///
  /// In en, this message translates to:
  /// **'Select the city of operation'**
  String get select_city_of_operation;

  /// No description provided for @search_city.
  ///
  /// In en, this message translates to:
  /// **'Search City'**
  String get search_city;

  /// No description provided for @upload_rc_document.
  ///
  /// In en, this message translates to:
  /// **'Upload RC Document *'**
  String get upload_rc_document;

  /// No description provided for @rc_front_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Front Uploaded'**
  String get rc_front_uploaded;

  /// No description provided for @rc_front_side.
  ///
  /// In en, this message translates to:
  /// **'Front Side'**
  String get rc_front_side;

  /// No description provided for @rc_back_uploaded.
  ///
  /// In en, this message translates to:
  /// **'Back Uploaded'**
  String get rc_back_uploaded;

  /// No description provided for @rc_back_side.
  ///
  /// In en, this message translates to:
  /// **'Back Side'**
  String get rc_back_side;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @continue_btn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_btn;

  /// No description provided for @please_enter_vehicle_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter vehicle number'**
  String get please_enter_vehicle_number;

  /// No description provided for @please_upload_both_rc.
  ///
  /// In en, this message translates to:
  /// **'Please upload both RC front and back'**
  String get please_upload_both_rc;

  /// No description provided for @please_select_city.
  ///
  /// In en, this message translates to:
  /// **'Please select city'**
  String get please_select_city;

  /// No description provided for @please_select_vehicle_type.
  ///
  /// In en, this message translates to:
  /// **'Please select vehicle type'**
  String get please_select_vehicle_type;

  /// No description provided for @please_select_vehicle_body_detail.
  ///
  /// In en, this message translates to:
  /// **'Please select vehicle body detail'**
  String get please_select_vehicle_body_detail;

  /// No description provided for @please_select_body_type.
  ///
  /// In en, this message translates to:
  /// **'Please select body type'**
  String get please_select_body_type;

  /// No description provided for @please_select_fuel_type.
  ///
  /// In en, this message translates to:
  /// **'Please select fuel type'**
  String get please_select_fuel_type;

  /// No description provided for @profile_not_loaded.
  ///
  /// In en, this message translates to:
  /// **'Profile not loaded. Try again.'**
  String get profile_not_loaded;

  /// No description provided for @registration_failed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registration_failed;

  /// No description provided for @file_size_too_large.
  ///
  /// In en, this message translates to:
  /// **'File sizes too large. Try smaller images.'**
  String get file_size_too_large;

  /// No description provided for @request_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Check internet and try again.'**
  String get request_timeout;

  /// No description provided for @registration_failed_with_error.
  ///
  /// In en, this message translates to:
  /// **'Registration failed:'**
  String get registration_failed_with_error;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @please_select_driver_option.
  ///
  /// In en, this message translates to:
  /// **'Please select if you will be driving the vehicle'**
  String get please_select_driver_option;

  /// No description provided for @please_enter_driver_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter driver name'**
  String get please_enter_driver_name;

  /// No description provided for @please_upload_front_license.
  ///
  /// In en, this message translates to:
  /// **'Please upload front license'**
  String get please_upload_front_license;

  /// No description provided for @please_upload_back_license.
  ///
  /// In en, this message translates to:
  /// **'Please upload back license'**
  String get please_upload_back_license;

  /// No description provided for @add_driver_detail.
  ///
  /// In en, this message translates to:
  /// **'Add Driver Detail'**
  String get add_driver_detail;

  /// No description provided for @i_will_be_driving_vehicle.
  ///
  /// In en, this message translates to:
  /// **'I will be driving this vehicle *'**
  String get i_will_be_driving_vehicle;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @driver_name.
  ///
  /// In en, this message translates to:
  /// **'Driver Name:'**
  String get driver_name;

  /// No description provided for @upload_driver_license.
  ///
  /// In en, this message translates to:
  /// **'Upload Driver License *'**
  String get upload_driver_license;

  /// No description provided for @license_front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get license_front;

  /// No description provided for @license_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get license_back;

  /// No description provided for @owner_detail_submitted.
  ///
  /// In en, this message translates to:
  /// **'Owner details submitted successfully!'**
  String get owner_detail_submitted;

  /// No description provided for @owner_details.
  ///
  /// In en, this message translates to:
  /// **'Owner Details'**
  String get owner_details;

  /// No description provided for @no_data_found.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get no_data_found;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @exit_app.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get exit_app;

  /// No description provided for @are_you_sure_you_want.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit this app?'**
  String get are_you_sure_you_want;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @pending_dues_found.
  ///
  /// In en, this message translates to:
  /// **'Pending dues found.'**
  String get pending_dues_found;

  /// No description provided for @account_deactivate.
  ///
  /// In en, this message translates to:
  /// **'Account Deactivated'**
  String get account_deactivate;

  /// No description provided for @account_deactivated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deactivated.\nPlease contact the admin for assistance.'**
  String get account_deactivated;

  /// No description provided for @hi.
  ///
  /// In en, this message translates to:
  /// **'Hii'**
  String get hi;

  /// No description provided for @welcome_to_yoyomiles.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Yoyomiles'**
  String get welcome_to_yoyomiles;

  /// No description provided for @few_steps_away.
  ///
  /// In en, this message translates to:
  /// **'You are now a few steps away from getting your first trip'**
  String get few_steps_away;

  /// No description provided for @document_pending_approval.
  ///
  /// In en, this message translates to:
  /// **'Your document has been successfully uploaded and is pending approval. Please wait while the review process is completed.'**
  String get document_pending_approval;

  /// No description provided for @foreground_location_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Foreground Location Access Permissions Required'**
  String get foreground_location_permission_required;

  /// No description provided for @location_permission_description.
  ///
  /// In en, this message translates to:
  /// **'This app collects your location even when the app is closed or not in use to enable ride matching, show nearby ride requests, and keep you available while you are online as a driver.'**
  String get location_permission_description;

  /// No description provided for @location_permission_required.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required'**
  String get location_permission_required;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @upload_documents.
  ///
  /// In en, this message translates to:
  /// **'Upload documents'**
  String get upload_documents;

  /// No description provided for @upload_documents_description.
  ///
  /// In en, this message translates to:
  /// **'Driving licence, Aadhaar card, etc.'**
  String get upload_documents_description;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @get_your_trip.
  ///
  /// In en, this message translates to:
  /// **'Get your trip..!!'**
  String get get_your_trip;

  /// No description provided for @voila_ready_for_trip.
  ///
  /// In en, this message translates to:
  /// **'Voila! You are ready to do your trip'**
  String get voila_ready_for_trip;

  /// No description provided for @go_online.
  ///
  /// In en, this message translates to:
  /// **'Go Online'**
  String get go_online;

  /// No description provided for @upload_again.
  ///
  /// In en, this message translates to:
  /// **'Upload Again'**
  String get upload_again;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @ride_history.
  ///
  /// In en, this message translates to:
  /// **'Ride History'**
  String get ride_history;

  /// No description provided for @wallet_and_settlement.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Settlement'**
  String get wallet_and_settlement;

  /// No description provided for @earning_report.
  ///
  /// In en, this message translates to:
  /// **'Earning Report'**
  String get earning_report;

  /// No description provided for @professional_driver.
  ///
  /// In en, this message translates to:
  /// **'Professional Driver'**
  String get professional_driver;

  /// No description provided for @personal_information.
  ///
  /// In en, this message translates to:
  /// **'Personal Information:'**
  String get personal_information;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number:'**
  String get phone_number;

  /// No description provided for @owner_name.
  ///
  /// In en, this message translates to:
  /// **'Owner Name:'**
  String get owner_name;

  /// No description provided for @vehicle_number_label.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number:'**
  String get vehicle_number_label;

  /// No description provided for @vehicle_information.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Information:'**
  String get vehicle_information;

  /// No description provided for @vehicle_body_type.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Body Type:'**
  String get vehicle_body_type;

  /// No description provided for @vehicle_name.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name:'**
  String get vehicle_name;

  /// No description provided for @aadhaar_card.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Card:'**
  String get aadhaar_card;

  /// No description provided for @pan_card.
  ///
  /// In en, this message translates to:
  /// **'PAN Card:'**
  String get pan_card;

  /// No description provided for @driving_licence.
  ///
  /// In en, this message translates to:
  /// **'Driving Licence'**
  String get driving_licence;

  /// No description provided for @rc_document.
  ///
  /// In en, this message translates to:
  /// **'RC Document'**
  String get rc_document;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirm_logout;

  /// No description provided for @logout_warning.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to access your account.'**
  String get logout_warning;

  /// No description provided for @log_out.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get log_out;

  /// No description provided for @no_rides_yet.
  ///
  /// In en, this message translates to:
  /// **'No rides yet'**
  String get no_rides_yet;

  /// No description provided for @ride_history_placeholder.
  ///
  /// In en, this message translates to:
  /// **'Your ride history will appear here'**
  String get ride_history_placeholder;

  /// No description provided for @sender_details.
  ///
  /// In en, this message translates to:
  /// **'Sender Details'**
  String get sender_details;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @receiver_details.
  ///
  /// In en, this message translates to:
  /// **'Receiver Details'**
  String get receiver_details;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @ride_completed.
  ///
  /// In en, this message translates to:
  /// **'Ride Completed'**
  String get ride_completed;

  /// No description provided for @cancelled_by_user.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by User'**
  String get cancelled_by_user;

  /// No description provided for @cancelled_by_driver.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by Driver'**
  String get cancelled_by_driver;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @ride_rating.
  ///
  /// In en, this message translates to:
  /// **'Ride Rating'**
  String get ride_rating;

  /// No description provided for @not_available.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get not_available;

  /// No description provided for @pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get pickup;

  /// No description provided for @location_not_specified.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get location_not_specified;

  /// No description provided for @dropoff.
  ///
  /// In en, this message translates to:
  /// **'Dropoff'**
  String get dropoff;

  /// No description provided for @available_balance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get available_balance;

  /// No description provided for @main_wallet.
  ///
  /// In en, this message translates to:
  /// **'Main Wallet'**
  String get main_wallet;

  /// No description provided for @due_wallet.
  ///
  /// In en, this message translates to:
  /// **'Due Wallet'**
  String get due_wallet;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @bank_history.
  ///
  /// In en, this message translates to:
  /// **'Bank History'**
  String get bank_history;

  /// No description provided for @add_bank.
  ///
  /// In en, this message translates to:
  /// **'Add Bank'**
  String get add_bank;

  /// No description provided for @recent_transactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recent_transactions;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount:'**
  String get total_amount;

  /// No description provided for @platform_fee.
  ///
  /// In en, this message translates to:
  /// **'Platform Fee:'**
  String get platform_fee;

  /// No description provided for @final_amount.
  ///
  /// In en, this message translates to:
  /// **'Final Amount:'**
  String get final_amount;

  /// No description provided for @paid_from_user_wallet.
  ///
  /// In en, this message translates to:
  /// **'Paid from User Wallet'**
  String get paid_from_user_wallet;

  /// No description provided for @online_payment.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get online_payment;

  /// No description provided for @due_payment.
  ///
  /// In en, this message translates to:
  /// **'Due Payment'**
  String get due_payment;

  /// No description provided for @offline_payment.
  ///
  /// In en, this message translates to:
  /// **'Offline Payment'**
  String get offline_payment;

  /// No description provided for @from_user_wallet.
  ///
  /// In en, this message translates to:
  /// **'From User Wallet'**
  String get from_user_wallet;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @withdraw_funds.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Funds'**
  String get withdraw_funds;

  /// No description provided for @enter_amount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enter_amount;

  /// No description provided for @no_bank_account_added.
  ///
  /// In en, this message translates to:
  /// **'No bank account has been added,\nplease add a bank account first.'**
  String get no_bank_account_added;

  /// No description provided for @earnings_report.
  ///
  /// In en, this message translates to:
  /// **'Earnings Report'**
  String get earnings_report;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @total_earnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get total_earnings;

  /// No description provided for @this_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get this_week;

  /// No description provided for @trips_completed.
  ///
  /// In en, this message translates to:
  /// **'Trips Completed'**
  String get trips_completed;

  /// No description provided for @online_hours.
  ///
  /// In en, this message translates to:
  /// **'Online Hours'**
  String get online_hours;

  /// No description provided for @trip_details.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get trip_details;

  /// No description provided for @no_trips_available.
  ///
  /// In en, this message translates to:
  /// **'No trips available'**
  String get no_trips_available;

  /// No description provided for @trip.
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// No description provided for @are_yor_sure_go_offline.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to go offline?'**
  String get are_yor_sure_go_offline;

  /// No description provided for @switch_online_later.
  ///
  /// In en, this message translates to:
  /// **'You can always switch back online later.'**
  String get switch_online_later;

  /// No description provided for @waiting_new_ride_request.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a new ride request…'**
  String get waiting_new_ride_request;

  /// No description provided for @stay_online_receive_booking.
  ///
  /// In en, this message translates to:
  /// **'Stay online and you\'ll receive a booking as soon as a customer requests a ride.'**
  String get stay_online_receive_booking;

  /// No description provided for @available_bookings.
  ///
  /// In en, this message translates to:
  /// **'Available Bookings'**
  String get available_bookings;

  /// No description provided for @booking_id.
  ///
  /// In en, this message translates to:
  /// **'Booking ID'**
  String get booking_id;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @ignore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// No description provided for @sender.
  ///
  /// In en, this message translates to:
  /// **'Sender'**
  String get sender;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @drop.
  ///
  /// In en, this message translates to:
  /// **'Drop'**
  String get drop;

  /// No description provided for @payment_successful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get payment_successful;

  /// No description provided for @payment_received_thank_you.
  ///
  /// In en, this message translates to:
  /// **'Payment has been successfully received. Thank you!'**
  String get payment_received_thank_you;

  /// No description provided for @ok_pressed_navigate_register.
  ///
  /// In en, this message translates to:
  /// **'🏠 OK pressed from success - Navigating to Register'**
  String get ok_pressed_navigate_register;

  /// No description provided for @ride_completed_celebration.
  ///
  /// In en, this message translates to:
  /// **'Ride Completed! 🎉🎉'**
  String get ride_completed_celebration;

  /// No description provided for @ride_completed_successfully_thank_you.
  ///
  /// In en, this message translates to:
  /// **'Your ride has been completed successfully. Thank you!'**
  String get ride_completed_successfully_thank_you;

  /// No description provided for @ride_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Ride Cancelled!'**
  String get ride_cancelled;

  /// No description provided for @ride_cancelled_by.
  ///
  /// In en, this message translates to:
  /// **'Ride has been cancelled by'**
  String get ride_cancelled_by;

  /// No description provided for @ride_completed_wallet.
  ///
  /// In en, this message translates to:
  /// **'Ride completed successfully (Wallet)'**
  String get ride_completed_wallet;

  /// No description provided for @reached_destination.
  ///
  /// In en, this message translates to:
  /// **'Reached destination!'**
  String get reached_destination;

  /// No description provided for @ride_status_reached_destination.
  ///
  /// In en, this message translates to:
  /// **'Ride status updated: Reached destination'**
  String get ride_status_reached_destination;

  /// No description provided for @failed_update_ride_status.
  ///
  /// In en, this message translates to:
  /// **'Failed to update ride status:'**
  String get failed_update_ride_status;

  /// No description provided for @otp_verified.
  ///
  /// In en, this message translates to:
  /// **'OTP Verified'**
  String get otp_verified;

  /// No description provided for @open_google_maps_navigation.
  ///
  /// In en, this message translates to:
  /// **'You can now open Google Maps for navigation.'**
  String get open_google_maps_navigation;

  /// No description provided for @go_to_map.
  ///
  /// In en, this message translates to:
  /// **'Go to Map'**
  String get go_to_map;

  /// No description provided for @go_to_pickup_location.
  ///
  /// In en, this message translates to:
  /// **'Go to Pickup Location'**
  String get go_to_pickup_location;

  /// No description provided for @open_google_maps_pickup.
  ///
  /// In en, this message translates to:
  /// **'Open Google Maps to navigate to pickup location.'**
  String get open_google_maps_pickup;

  /// No description provided for @could_not_open_google_maps.
  ///
  /// In en, this message translates to:
  /// **'Could not open Google Maps'**
  String get could_not_open_google_maps;

  /// No description provided for @start_for_pickup.
  ///
  /// In en, this message translates to:
  /// **'Start for Pickup'**
  String get start_for_pickup;

  /// No description provided for @arrived_at_pickup_point.
  ///
  /// In en, this message translates to:
  /// **'Arrived at Pickup Point'**
  String get arrived_at_pickup_point;

  /// No description provided for @start_ride.
  ///
  /// In en, this message translates to:
  /// **'Start Ride'**
  String get start_ride;

  /// No description provided for @reached.
  ///
  /// In en, this message translates to:
  /// **'Reached'**
  String get reached;

  /// No description provided for @trip_otp_verification.
  ///
  /// In en, this message translates to:
  /// **'Trip OTP Verification'**
  String get trip_otp_verification;

  /// No description provided for @otp_verified_ride_started.
  ///
  /// In en, this message translates to:
  /// **'OTP verified! Ride started.'**
  String get otp_verified_ride_started;

  /// No description provided for @invalid_otp_try_again.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP. Try again'**
  String get invalid_otp_try_again;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @support_help_message.
  ///
  /// In en, this message translates to:
  /// **'Hello Support, I need help with my ongoing ride.'**
  String get support_help_message;

  /// No description provided for @accepted_by_driver.
  ///
  /// In en, this message translates to:
  /// **'Accepted by Driver'**
  String get accepted_by_driver;

  /// No description provided for @out_for_pickup.
  ///
  /// In en, this message translates to:
  /// **'Out for PickUp'**
  String get out_for_pickup;

  /// No description provided for @at_pickup_point.
  ///
  /// In en, this message translates to:
  /// **'At Pickup Point'**
  String get at_pickup_point;

  /// No description provided for @ride_started.
  ///
  /// In en, this message translates to:
  /// **'Ride Started'**
  String get ride_started;

  /// No description provided for @reached_destination_status.
  ///
  /// In en, this message translates to:
  /// **'Reached Destination'**
  String get reached_destination_status;

  /// No description provided for @payment_completed.
  ///
  /// In en, this message translates to:
  /// **'Payment Completed'**
  String get payment_completed;

  /// No description provided for @ride_cancelled_status.
  ///
  /// In en, this message translates to:
  /// **'Ride Cancelled'**
  String get ride_cancelled_status;

  /// No description provided for @unknown_status.
  ///
  /// In en, this message translates to:
  /// **'Unknown Status'**
  String get unknown_status;

  /// No description provided for @no_active_ride.
  ///
  /// In en, this message translates to:
  /// **'No Active Ride'**
  String get no_active_ride;

  /// No description provided for @no_active_ride_message.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active ride at the moment'**
  String get no_active_ride_message;

  /// No description provided for @vehicle_type.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Type'**
  String get vehicle_type;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @current_status.
  ///
  /// In en, this message translates to:
  /// **'Current Status:'**
  String get current_status;

  /// No description provided for @ride_status_start_pickup.
  ///
  /// In en, this message translates to:
  /// **'Ride status updated: Start for Pickup Location'**
  String get ride_status_start_pickup;

  /// No description provided for @ride_status_arrived_pickup.
  ///
  /// In en, this message translates to:
  /// **'Ride status updated: Arrived at Pickup Point'**
  String get ride_status_arrived_pickup;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @ride_completed_successfully.
  ///
  /// In en, this message translates to:
  /// **'Ride completed successfully!'**
  String get ride_completed_successfully;

  /// No description provided for @failed_complete_ride.
  ///
  /// In en, this message translates to:
  /// **'Failed to complete ride:'**
  String get failed_complete_ride;

  /// No description provided for @failed_change_payment_mode.
  ///
  /// In en, this message translates to:
  /// **'Failed to change payment mode:'**
  String get failed_change_payment_mode;

  /// No description provided for @change_payment_mode.
  ///
  /// In en, this message translates to:
  /// **'Change Payment Mode'**
  String get change_payment_mode;

  /// No description provided for @changing_payment_mode.
  ///
  /// In en, this message translates to:
  /// **'Changing payment mode...'**
  String get changing_payment_mode;

  /// No description provided for @cash_payment.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment'**
  String get cash_payment;

  /// No description provided for @change_pay_mode.
  ///
  /// In en, this message translates to:
  /// **'Change Pay Mode'**
  String get change_pay_mode;

  /// No description provided for @collect_cash_from_customer.
  ///
  /// In en, this message translates to:
  /// **'Please collect cash payment from customer'**
  String get collect_cash_from_customer;

  /// No description provided for @pay_done.
  ///
  /// In en, this message translates to:
  /// **'Pay Done'**
  String get pay_done;

  /// No description provided for @payment_completed_celebration.
  ///
  /// In en, this message translates to:
  /// **'Payment Completed! 🎉'**
  String get payment_completed_celebration;

  /// No description provided for @customer_completed_online_payment.
  ///
  /// In en, this message translates to:
  /// **'Customer has successfully completed the online payment.'**
  String get customer_completed_online_payment;

  /// No description provided for @wait_for_customer_payment.
  ///
  /// In en, this message translates to:
  /// **'Please wait while the customer completes the online payment.'**
  String get wait_for_customer_payment;

  /// No description provided for @waiting_for_payment.
  ///
  /// In en, this message translates to:
  /// **'Waiting for payment...'**
  String get waiting_for_payment;

  /// No description provided for @please_enter_otp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get please_enter_otp;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get change_language;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'hi': return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
