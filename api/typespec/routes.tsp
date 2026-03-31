using Http;
using Versioning;

namespace PetStore;

@route("/pets")
namespace Pets {
  @get
  op listPets(@query limit?: int32, @query cursor?: string): {
    @statusCode statusCode: 200;
    @body body: PetPage;
  };

  @get
  op getPet(@path petId: int64): {
    @statusCode statusCode: 200;
    @body body: Pet;
  } | {
    @statusCode statusCode: 404;
    @body body: Error;
  };

  @post
  op createPet(@body body: NewPet): {
    @statusCode statusCode: 201;
    @body body: Pet;
  } | {
    @statusCode statusCode: 400;
    @body body: Error;
  };

  @put
  op updatePet(@path petId: int64, @body body: UpdatePet): {
    @statusCode statusCode: 200;
    @body body: Pet;
  } | {
    @statusCode statusCode: 404;
    @body body: Error;
  } | {
    @statusCode statusCode: 400;
    @body body: Error;
  };

  @delete
  op deletePet(@path petId: int64): {
    @statusCode statusCode: 204;
  } | {
    @statusCode statusCode: 404;
    @body body: Error;
  };

  @added(Versions.v2)
  @route("{petId}/tags")
  @get
  op listPetTags(@path petId: int64): {
    @statusCode statusCode: 200;
    @body body: string[];
  } | {
    @statusCode statusCode: 404;
    @body body: Error;
  };
}

@route("/health")
namespace Health {
  @get
  op healthCheck(): {
    @statusCode statusCode: 200;
    @body body: {
      status: string;
    };
  };
}
