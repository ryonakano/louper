/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#pragma once

#include <gtk/gtk.h>

G_BEGIN_DECLS

#define LOUPER_TYPE_APPLICATION (louper_application_get_type ())
G_DECLARE_FINAL_TYPE (LouperApplication, louper_application, LOUPER, APPLICATION, GtkApplication)

extern LouperApplication *louper_application_new (void);

G_END_DECLS
