///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsEn = Translations; // ignore: unused_element
class Translations implements BaseTranslations<AppLocale, Translations> {
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
	String get title => 'Alfred';
	late final TranslationsLoadingEn loading = TranslationsLoadingEn._(_root);
	late final TranslationsRosConnectionEn ros_connection = TranslationsRosConnectionEn._(_root);
	late final TranslationsTableMappingEn table_mapping = TranslationsTableMappingEn._(_root);
	late final TranslationsOrderDeliveryEn order_delivery = TranslationsOrderDeliveryEn._(_root);
	String get save => 'Save';
	String get next => 'Next';
	String get send => 'Send';
}

// Path: loading
class TranslationsLoadingEn {
	TranslationsLoadingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Initializing System';
	String get connecting => 'Connecting to ROS...';
	String get connected => 'Connected successfully!';
	String get failed => 'Connection failed. Retrying...';
}

// Path: ros_connection
class TranslationsRosConnectionEn {
	TranslationsRosConnectionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'ROS Connection';
	String get status => 'Connection Status:';
	String get connected => 'Connected';
	String get disconnected => 'Disconnected';
}

// Path: table_mapping
class TranslationsTableMappingEn {
	TranslationsTableMappingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Table Mapping';
	String get instruction => 'Move the robot to the table location';
	String get pose => 'Pose:';
	String get orientation => 'Orientation:';
}

// Path: order_delivery
class TranslationsOrderDeliveryEn {
	TranslationsOrderDeliveryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Order Delivery';
	String get no_tables => 'No tables mapped yet';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.
extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'title': return 'Alfred';
			case 'loading.title': return 'Initializing System';
			case 'loading.connecting': return 'Connecting to ROS...';
			case 'loading.connected': return 'Connected successfully!';
			case 'loading.failed': return 'Connection failed. Retrying...';
			case 'ros_connection.title': return 'ROS Connection';
			case 'ros_connection.status': return 'Connection Status:';
			case 'ros_connection.connected': return 'Connected';
			case 'ros_connection.disconnected': return 'Disconnected';
			case 'table_mapping.title': return 'Table Mapping';
			case 'table_mapping.instruction': return 'Move the robot to the table location';
			case 'table_mapping.pose': return 'Pose:';
			case 'table_mapping.orientation': return 'Orientation:';
			case 'order_delivery.title': return 'Order Delivery';
			case 'order_delivery.no_tables': return 'No tables mapped yet';
			case 'save': return 'Save';
			case 'next': return 'Next';
			case 'send': return 'Send';
			default: return null;
		}
	}
}

