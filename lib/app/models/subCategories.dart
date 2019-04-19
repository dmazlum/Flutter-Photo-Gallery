class SubCategories {
  final bool error;
  final String message;
  final String type;
  final String template;
  final List<SubCategoriesModel> subdata;
  final List<Galleries> gallery;
  final String mainCategory;
  final String catname;

  SubCategories(
    this.error,
    this.message,
    this.type,
    this.template,
    this.subdata,
    this.gallery,
    this.mainCategory,
    this.catname,
  );
}

class SubCategoriesModel {
  var id;
  var subCategoryId;
  final String sectionName;
  final String sectionPhoto;

  SubCategoriesModel(
    this.id,
    this.subCategoryId,
    this.sectionName,
    this.sectionPhoto,
  );
}

class Galleries {
  var id;
  var galleryId;
  final String photoName;

  Galleries(
    this.id,
    this.galleryId,
    this.photoName,
  );
}
