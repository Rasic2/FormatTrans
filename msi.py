import tokenize

import numpy as np


class FormatError(IOError):
    pass


class MSIModel(object):
    def __init__(self):
        self.name = None
        self.space_group = None
        self.lattice = None
        self.atoms = []


class MSIAtom(object):
    def __init__(self):
        self.formula = None
        self.coord = []

    def __repr__(self):
        return f"<{self.formula} {self.coord}>"


class MSIParser(object):
    def __init__(self, file):
        self.file = file
        self._tokens = self.__initialize_tokens()
        self.model_stack = []
        self.atom_stack = []
        self.attr_stack = []
        self.array_stack = []

    def __initialize_tokens(self):
        tokens_list = []
        with tokenize.open(self.file) as f:
            tokens = tokenize.generate_tokens(f.readline)
            for token in tokens:
                tokens_list.append(token)
        return tokens_list

    def parse(self):
        lattice = []
        for index, token in enumerate(self._tokens):
            if token.type == 54 and token.string == "(":  # Begin token
                if token.line == '(1 Model\n':
                    self.model_stack.append(token)
                    model = MSIModel()
                elif self._tokens[index + 1].string == "A":
                    self.attr_stack.append(token)
                elif self._tokens[index + 2].string == "Atom":
                    self.atom_stack.append(token)
                    atom = MSIAtom()
                    coord = []
                elif self._tokens[index - 1].string in ["A3", "B3", "C3", "XYZ"]:
                    self.array_stack.append(token)
            elif token.type == 54 and token.string == ")":  # End token
                if len(self.model_stack):
                    if len(self.attr_stack):
                        self.attr_stack.pop()
                    elif len(self.array_stack):
                        self.array_stack.pop()
                    elif len(self.atom_stack):
                        self.atom_stack.pop()
                        if getattr(atom, "formula") is not None:
                            atom.coord = np.array(coord)
                            model.atoms.append(atom)
                else:
                    raise FormatError("*.msi file format error and I can't parse it")
            else:
                if len(self.array_stack):
                    if not len(self.atom_stack):
                        lattice.append(float(token.string))  # parse lattice
                    else:
                        coord.append(float(token.string))
                if len(self.attr_stack):
                    if not len(self.atom_stack):
                        if index + 2 < len(self._tokens):
                            if self._tokens[index + 2].string == "Label":
                                model.name = self._tokens[index + 3].string
                            elif self._tokens[index + 2].string == "SpaceGroup":
                                if self._tokens[index + 3].string != '"1 1"':
                                    raise FormatError("Only supported the P1 symmetry")
                                else:
                                    model.space_group = "P1"
                    else:
                        if self._tokens[index + 2].string == "ACL":
                            atom.formula = self._tokens[index + 3].string.split()[-1]

        model.lattice = np.array(lattice).reshape((3, 3))

        return model


if __name__ == '__main__':
    parser = MSIParser("Structures/catalysts/heterogeneous/beta-A.msi")
    model = parser.parse()
    print()
