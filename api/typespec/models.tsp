using Http;
using Versioning;

namespace PetStore;

enum PetKind {
  dog,
  cat,
  fish,
  bird,
  reptile,
}

model Pet {
  id: int64;
  name: string;
  kind: PetKind;
  age: int32;
  createdAt: utcDateTime;
  updatedAt: utcDateTime;

  @added(Versions.v2)
  tags: string[];
}

model NewPet {
  @minLength(1)
  @maxLength(255)
  name: string;

  kind: PetKind;

  @minValue(0)
  @maxValue(100)
  age: int32;

  @added(Versions.v2)
  tags?: string[];
}

model UpdatePet {
  @minLength(1)
  @maxLength(255)
  name?: string;

  kind?: PetKind;

  @minValue(0)
  @maxValue(100)
  age?: int32;

  @added(Versions.v2)
  tags?: string[];
}

model PetPage {
  items: Pet[];
  nextCursor?: string;
}

model Error {
  code: string;
  message: string;
}
