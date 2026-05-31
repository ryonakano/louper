/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021-2026 Ryo Nakano <ryonakaknock3@gmail.com>
 */

#include <locale.h>
#include <glib/gi18n.h>
#include <gtk/gtk.h>
#include "config.h"
#include "application.h"

int
main (int    argc,
      char  *argv[])
{
    g_autoptr(LouperApplication) app;
    int ret;

    setlocale (LC_ALL, "");
    bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
    bind_textdomain_codeset (GETTEXT_PACKAGE, "UTF-8");
    textdomain (GETTEXT_PACKAGE);

    app = louper_application_new ();
    ret = g_application_run (G_APPLICATION (app), argc, argv);

    return ret;
}
