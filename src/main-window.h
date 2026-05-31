/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

G_BEGIN_DECLS

#define LOUPER_TYPE_MAIN_WINDOW         (louper_main_window_get_type ())
G_DECLARE_FINAL_TYPE (LouperMainWindow, louper_main_window, LOUPER, MAIN_WINDOW, GtkApplicationWindow)

extern LouperMainWindow *louper_main_window_new (void);

extern void louper_main_window_set_keep_open (LouperMainWindow *self, gboolean keep_open);
extern void louper_main_window_set_text (LouperMainWindow *self, const GString *text);

G_END_DECLS
