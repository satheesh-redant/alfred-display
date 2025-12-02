///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// en: 'Alfred'
	String get title => 'Alfred';

	late final TranslationsLoadingEn loading = TranslationsLoadingEn._(_root);
	late final TranslationsRosConnectionEn ros_connection = TranslationsRosConnectionEn._(_root);
	late final TranslationsTableMappingEn table_mapping = TranslationsTableMappingEn._(_root);
	late final TranslationsOrderDeliveryEn order_delivery = TranslationsOrderDeliveryEn._(_root);

	/// en: 'Save'
	String get save => 'Save';

	/// en: 'Next'
	String get next => 'Next';

	/// en: 'Send'
	String get send => 'Send';
}

// Path: loading
class TranslationsLoadingEn {
	TranslationsLoadingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Initializing System'
	String get title => 'Initializing System';

	/// en: 'Connecting to ROS...'
	String get connecting => 'Connecting to ROS...';

	/// en: 'Connected successfully!'
	String get connected => 'Connected successfully!';

	/// en: 'Connection failed. Retrying...'
	String get failed => 'Connection failed. Retrying...';
}

// Path: ros_connection
class TranslationsRosConnectionEn {
	TranslationsRosConnectionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'ROS Connection'
	String get title => 'ROS Connection';

	/// en: 'Connection Status:'
	String get status => 'Connection Status:';

	/// en: 'Connected'
	String get connected => 'Connected';

	/// en: 'Disconnected'
	String get disconnected => 'Disconnected';
}

// Path: table_mapping
class TranslationsTableMappingEn {
	TranslationsTableMappingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Table Mapping'
	String get title => 'Table Mapping';

	/// en: 'Move the robot to the table location'
	String get instruction => 'Move the robot to the table location';

	/// en: 'Pose:'
	String get pose => 'Pose:';

	/// en: 'Orientation:'
	String get orientation => 'Orientation:';
}

// Path: order_delivery
class TranslationsOrderDeliveryEn {
	TranslationsOrderDeliveryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// en: 'Order Delivery'
	String get title => 'Order Delivery';

	/// en: 'No tables mapped yet'
	String get no_tables => 'No tables mapped yet';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'title' => 'Alfred',
			'loading.title' => 'Initializing System',
			'loading.connecting' => 'Connecting to ROS...',
			'loading.connected' => 'Connected successfully!',
			'loading.failed' => 'Connection failed. Retrying...',
			'ros_connection.title' => 'ROS Connection',
			'ros_connection.status' => 'Connection Status:',
			'ros_connection.connected' => 'Connected',
			'ros_connection.disconnected' => 'Disconnected',
			'table_mapping.title' => 'Table Mapping',
			'table_mapping.instruction' => 'Move the robot to the table location',
			'table_mapping.pose' => 'Pose:',
			'table_mapping.orientation' => 'Orientation:',
			'order_delivery.title' => 'Order Delivery',
			'order_delivery.no_tables' => 'No tables mapped yet',
			'save' => 'Save',
			'next' => 'Next',
			'send' => 'Send',
			_ => null,
		};
	}
}
