/*
 * UndoableCreateLinkAnnotation.java
 *
 * Copyright (c) 2010 Flaviano Petrocchi <flavianopetrocchi at gmail.com>.
 * All rights reserved.
 *
 * This file is part of JPdfBookmarks.
 *
 * JPdfBookmarks is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * JPdfBookmarks is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with JPdfBookmarks.  If not, see <http://www.gnu.org/licenses/>.
 */
package it.flavianopetrocchi.jpdfbookmarks;

import it.flavianopetrocchi.jpdfbookmarks.bookmark.IBookmarksConverter;
import javax.swing.undo.AbstractUndoableEdit;
import javax.swing.undo.CannotRedoException;
import javax.swing.undo.CannotUndoException;

public class UndoableCreateLinkAnnotation extends AbstractUndoableEdit {

    private final UnifiedFileOperator fileOperator;
    private final IBookmarksConverter.LinkAnnotationSpec spec;

    public UndoableCreateLinkAnnotation(UnifiedFileOperator fileOperator,
            IBookmarksConverter.LinkAnnotationSpec spec) {
        this.fileOperator = fileOperator;
        this.spec = spec;
    }

    public void doEdit() {
        fileOperator.addPendingLinkAnnotation(spec);
    }

    @Override
    public void undo() throws CannotUndoException {
        super.undo();
        fileOperator.removePendingLinkAnnotation(spec);
    }

    @Override
    public void redo() throws CannotRedoException {
        super.redo();
        fileOperator.addPendingLinkAnnotation(spec);
    }
}
